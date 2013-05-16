%implementation of a simple M/M/k

% clear
clear;
clc;

% simulating parameters
sim_num = 64;                       % simulation times
sim_packets = 800;                  % number of clients to be simulated

% queueing system parameters
k = 2;                              % M/M/k
queue_lim = 200000;                 % system limit
service_mean_time=0.01;             % miu
arrival_mean_time(1:sim_num+1)=0.01;% lamda

% result vectors
util(1:sim_num+1) = 0;
avg_num_in_queue(1:sim_num+1) = 0;
avg_delay_in_queue(1:sim_num+1) = 0;
P(1:sim_num+1) = 1;


% performing sim_num times simulations
for j=1:sim_num
    
    % increasing the mean arrrival time
    arrival_mean_time(j+1)=arrival_mean_time(j) + 0.001;
    
    % initialization
    sim_time = 0.0;
    time_last_event=0.0;
    
    server_status(1:k) = 0;                 % all servers empty at first
    num_server_busy=0;

    num_clients_count=0;                    % number of clients ever entered system
    num_clients_in_queue=0;                 % number of pkts in queue
    
    time_in_queue=0.0;
    time_in_server=0.0;
    
    % next arrival event
    time_next_arrival_event = sim_time + exprnd(arrival_mean_time(j+1));
    
    % next departure events
    time_next_departure_event(1:k) = exp(30);
    % well, even so, next arrival time may exceed it. but we ignore it here
        
    disp(['Launching Simulation...',num2str(j)]);
    
    while(num_clients_count < sim_packets)
        
        min_time_next_event = exp(29);
        
        % 0 for no event; -1 for arrival event; i>0 for departure from server i event
        type_of_event = 0;
        
        if (time_next_arrival_event < min_time_next_event)
            min_time_next_event = time_next_arrival_event;
            type_of_event = -1; % arrival event 
        end
        
        for i=1:k
            if(time_next_departure_event(i) < min_time_next_event)
                min_time_next_event = time_next_departure_event(i);
                type_of_event = i; % depature from server i event
            end;
        end
        
        if(type_of_event == 0)
            disp(['no event in time ',num2str(sim_time)]);
        end
        
        % update the time values
        sim_time = min_time_next_event;
        time_since_last_event = sim_time - time_last_event;
        time_last_event = sim_time;
        
        time_in_queue = time_in_queue + num_clients_in_queue * time_since_last_event ;
        
        time_in_server = time_in_server + num_server_busy * time_since_last_event;
        
        
        if (type_of_event == -1)
            % --------------------- arrival --------------------------
            num_clients_count = num_clients_count + 1;
            time_next_arrival_event = sim_time + exprnd(arrival_mean_time(j+1));
            
            if(num_server_busy == k)
                
                num_clients_in_queue = num_clients_in_queue + 1 ;
                
                if(num_clients_in_queue > queue_lim)
                    disp(['queue size = ', num2str(num_clients_in_queue)]);
                    disp(['System Crash at ',num2str(sim_time)]);
                    pause
                end
                
            else
                num_server_busy = num_server_busy + 1;
                
                empty_servers = find(server_status == 0);
                empty_servers = empty_servers(randperm(length(empty_servers)));
                server_status(empty_servers(1)) = 1;
                time_next_departure_event(empty_servers(1)) = sim_time + exprnd(service_mean_time);
            end
            
        elseif (type_of_event > 0)
            % ---------------------- departure -----------------------
            server_status(type_of_event) = 0;
            time_next_departure_event(type_of_event) = exp(30);

            if(num_clients_in_queue == 0)
                num_server_busy = num_server_busy - 1;                
            else
                num_clients_in_queue = num_clients_in_queue - 1;

                empty_servers = find(server_status == 0);
                empty_servers = empty_servers(randperm(length(empty_servers)));
                server_status(empty_servers(1)) = 1;
                time_next_departure_event(empty_servers(1)) = sim_time + exprnd(service_mean_time);
            end
            
        end
        
    end
    
    %results output
    util(j+1) = time_in_server/sim_time;
    avg_num_in_queue(j+1) = time_in_queue/sim_time;
    avg_delay_in_queue(j+1) = time_in_queue/num_clients_count;
    P(j+1) = service_mean_time./arrival_mean_time(j+1);
    
end

theoretical_avg_num_in_queue = (P .* (P .^ k))./(k * ((1 - P./k).^2)*factorial(k).*((P.^k)./(factorial(k)-P*factorial(k-1))+exp(P).*gammainc(k,P)./gamma(k)));
theoretical_avg_delay = (k*(P.^k)*gamma(k))./((k-P).*((k*(P.^k)*(1./service_mean_time)*gamma(k))-(exp(P).*((1./arrival_mean_time)-k*(1./service_mean_time))*factorial(k).*gammainc(k,P))));

%----------------------graphs--------------------------------
figure('name',['Mean Number of Clients in Queue (M/M/',int2str(k),')']);
plot(P,avg_num_in_queue,'r',P,theoretical_avg_num_in_queue,'b');
legend('simulation','theoretical');
title(['Mean Number of Clients in Queue (M/M/',int2str(k),')']);
xlabel('P');
ylabel('mean number of clients');
axis([0 0.91 0 1]);

figure('name',['Mean Delay in Queue (M/M/',int2str(k),')']);
plot(P,avg_delay_in_queue,'r',P,theoretical_avg_delay,'b');
legend('simulation','theoretical');
title(['Mean Delay in Queue (M/M/',int2str(k),')']);
xlabel('P');
ylabel('mean delay (hrs)');
axis([0 0.91 0 0.01]);

figure('name', ['Utilisation (M/M/',int2str(k),')']);
plot(P,util,'r',P,P,'b');
legend('simulation','theoretical');
title(['Utilisation (M/M/',int2str(k),')']);
xlabel('P');
ylabel('Utilisation');
axis([0 0.91 0 1]);



