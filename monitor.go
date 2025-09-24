package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/client"
)

// ANSI Colors
const (
	Red    = "\033[0;31m"
	Green  = "\033[0;32m"
	Yellow = "\033[1;33m"
	Blue   = "\033[0;34m"
	Purple = "\033[0;35m"
	Cyan   = "\033[0;36m"
	White  = "\033[1;37m"
	Gray   = "\033[0;90m"
	Reset  = "\033[0m"
)

// Service definition
type Service struct {
	Name      string
	Container string
	Port      string
	Type      string // "infra" or "micro"
}

// Container status
type ContainerStatus struct {
	Name    string
	Status  string
	Health  string
	Running bool
}

// Service definitions
var services = []Service{
	{"MongoDB", "ms-kotlin-mongodb", "27018", "infra"},
	{"MySQL", "ms-kotlin-mysql", "3307", "infra"},
	{"Zookeeper", "ms-kotlin-zookeeper", "2181", "infra"},
	{"Kafka", "ms-kotlin-kafka", "9092", "infra"},
	{"Kafka-UI", "ms-kotlin-kafka-ui", "8090", "infra"},
	{"Vault", "ms-kotlin-vault", "8200", "infra"},
	{"Config", "ms-kotlin-configuration-server", "8888", "micro"},
	{"Discovery", "ms-kotlin-discover-server", "8761", "micro"},
	{"Products", "ms-kotlin-product-service", "8082", "micro"},
	{"Orders", "ms-kotlin-order-service", "8083", "micro"},
}

func main() {
	// Parse arguments
	interval := 300 * time.Millisecond // Default 0.3s
	if len(os.Args) > 1 {
		switch os.Args[1] {
		case "-h", "--help":
			showHelp()
			return
		default:
			// Parse custom interval
			if duration, err := time.ParseDuration(os.Args[1] + "s"); err == nil {
				interval = duration
			}
		}
	}

	// Setup Docker client
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		fmt.Printf("❌ Error connecting to Docker: %v\n", err)
		fmt.Println("💡 Make sure Docker is running and accessible")
		os.Exit(1)
	}
	defer cli.Close()

	// Setup signal handling
	ctx, cancel := context.WithCancel(context.Background())
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		cancel()
	}()

	// Hide cursor
	fmt.Print("\033[?25l")
	defer fmt.Print("\033[?25h")

	fmt.Printf("%s🚀 Starting ultra-fast Go monitor (%.1fms refresh)...%s\n", 
		Cyan, float64(interval.Nanoseconds())/1e6, Reset)

	// Main monitoring loop
	for {
		select {
		case <-ctx.Done():
			fmt.Printf("\n%s👋 Monitor stopped%s\n", Gray, Reset)
			return
		default:
			start := time.Now()
			showDashboard(cli)
			duration := time.Since(start)
			
			fmt.Printf("%sUpdate: %.0fms | Next in %.0fms%s\n", 
				Gray, float64(duration.Nanoseconds())/1e6,
				float64(interval.Nanoseconds())/1e6, Reset)
			
			time.Sleep(interval)
		}
	}
}

// Get all container statuses concurrently
func getAllContainerStatus(cli *client.Client) map[string]ContainerStatus {
	ctx := context.Background()
	statusMap := make(map[string]ContainerStatus)
	
	// Get all containers with ms-kotlin prefix
	containers, err := cli.ContainerList(ctx, types.ContainerListOptions{All: true})
	if err != nil {
		return statusMap
	}

	// Process containers concurrently
	statusChan := make(chan ContainerStatus, len(services))
	
	for _, service := range services {
		go func(s Service) {
			status := ContainerStatus{
				Name:    s.Container,
				Status:  "NOT_RUNNING",
				Health:  "unknown",
				Running: false,
			}
			
			// Find container
			for _, container := range containers {
				for _, name := range container.Names {
					if strings.Contains(name, s.Container) {
						status.Status = container.State
						status.Running = container.State == "running"
						
						// Get health status if available
						if container.State == "running" {
							inspect, err := cli.ContainerInspect(ctx, container.ID)
							if err == nil && inspect.State.Health != nil {
								status.Health = inspect.State.Health.Status
							} else {
								status.Health = "no-healthcheck"
							}
						}
						break
					}
				}
			}
			statusChan <- status
		}(service)
	}
	
	// Collect results
	for i := 0; i < len(services); i++ {
		status := <-statusChan
		statusMap[status.Name] = status
	}
	
	return statusMap
}

// Get status display string
func getStatusDisplay(status ContainerStatus) string {
	switch {
	case status.Running && (status.Health == "healthy" || status.Health == "no-healthcheck"):
		return fmt.Sprintf("%s✅ HEALTHY%s", Green, Reset)
	case status.Running && status.Health == "starting":
		return fmt.Sprintf("%s⏳ STARTING%s", Yellow, Reset)
	case status.Running && status.Health == "unhealthy":
		return fmt.Sprintf("%s⚠️  UNHEALTHY%s", Red, Reset)
	case status.Status == "restarting":
		return fmt.Sprintf("%s🔄 RESTARTING%s", Yellow, Reset)
	case status.Status == "paused":
		return fmt.Sprintf("%s⏸️  PAUSED%s", Blue, Reset)
	default:
		return fmt.Sprintf("%s⚫ STOPPED%s", Gray, Reset)
	}
}

// Show dashboard
func showDashboard(cli *client.Client) {
	// Clear screen
	cmd := exec.Command("cmd", "/c", "cls")
	if exec.Command("clear").Run() == nil {
		cmd = exec.Command("clear")
	}
	cmd.Stdout = os.Stdout
	cmd.Run()

	statuses := getAllContainerStatus(cli)
	timestamp := time.Now().Format("15:04:05")
	
	var infraServices, microServices []string
	var total, healthy, starting, stopped int
	
	// Build service lists and count statuses
	for _, service := range services {
		status := statuses[service.Container]
		statusDisplay := getStatusDisplay(status)
		line := fmt.Sprintf("║ %-12s %s %s:%s", service.Name, statusDisplay, Cyan, service.Port)
		
		total++
		switch {
		case status.Running && (status.Health == "healthy" || status.Health == "no-healthcheck"):
			healthy++
		case status.Running && status.Health == "starting":
			starting++
		default:
			stopped++
		}
		
		if service.Type == "infra" {
			infraServices = append(infraServices, line)
		} else {
			microServices = append(microServices, line)
		}
	}
	
	// Summary message
	var summary string
	if healthy == total {
		summary = fmt.Sprintf("%s🎉 All services healthy%s", Green, Reset)
	} else if healthy+starting > 0 {
		summary = fmt.Sprintf("%s⏳ Services starting up%s", Yellow, Reset)
	} else {
		summary = fmt.Sprintf("%s🛑 No services running%s", Red, Reset)
	}
	
	// Display dashboard
	fmt.Printf("%s╔════════════════════════════════════════════════════════════════════╗%s\n", White, Reset)
	fmt.Printf("%s║%s %s🔍 Kotlin Microservices Monitor%s %s║%s %s%s%s %s║%s\n", 
		White, Reset, Cyan, Reset, White, Reset, Gray, timestamp, Reset, White, Reset)
	fmt.Printf("%s╠════════════════════════════════════════════════════════════════════╣%s\n", White, Reset)
	fmt.Printf("%s║%s %s🏗️  INFRASTRUCTURE%s                                            %s║%s\n", 
		White, Reset, White, Reset, White, Reset)
	
	for _, line := range infraServices {
		fmt.Printf("%s%s%s\n", line, Reset, White)
	}
	
	fmt.Printf("\n%s╠────────────────────────────────────────────────────────────────────╢%s\n", White, Reset)
	fmt.Printf("%s║%s %s🚀 MICROSERVICES%s                                               %s║%s\n", 
		White, Reset, White, Reset, White, Reset)
	
	for _, line := range microServices {
		fmt.Printf("%s%s%s\n", line, Reset, White)
	}
	
	fmt.Printf("\n%s╠════════════════════════════════════════════════════════════════════╣%s\n", White, Reset)
	fmt.Printf("%s║%s %s✅ %d%s %s⏳ %d%s %s❌ %d%s %s📊 %d%s │ %s                  %s║%s\n", 
		White, Reset, Green, healthy, Reset, Yellow, starting, Reset, Red, stopped, Reset, 
		Blue, total, Reset, summary, White, Reset)
	fmt.Printf("%s╚════════════════════════════════════════════════════════════════════╝%s\n", White, Reset)
	fmt.Printf("%s⚡ Ultra-fast Go monitor │ %sCtrl+C%s%s to exit │ %s./start-infra.sh%s %s./start-dev.sh%s%s to launch%s\n", 
		Gray, Cyan, Reset, Gray, Cyan, Reset, Cyan, Reset, Gray, Reset)
}

// Show help
func showHelp() {
	fmt.Printf("%s🔍 Ultra-Fast Go Microservices Monitor%s\n\n", Cyan, Reset)
	fmt.Println("Usage: ./monitor [INTERVAL]")
	fmt.Println()
	fmt.Println("Examples:")
	fmt.Println("  ./monitor           Ultra-fast (300ms refresh)")
	fmt.Println("  ./monitor 0.1       Blazing fast (100ms refresh)")
	fmt.Println("  ./monitor 1         Standard (1s refresh)")
	fmt.Println("  ./monitor -h        Show this help")
	fmt.Println()
	fmt.Printf("%sTip: Go version is 10-50x faster than bash version!%s\n", Gray, Reset)
}