%implementation of a simple M/M/1

% clear
clear;
clc;

% simulating parameters
sim_num = 64;                       % simulation times
sim_packets = 1000;                  % number of clients to be simulated

% queueing system parameters
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
    
    arrival_mean_time(j+1)=arrival_mean_time(j) + 0.001;
    
    num_events=2;
    
    % initialization
    sim_time = 0.0;
    time_last_event=0.0;

    server_status = 0;
    num_clients_count=0;
    num_clients_in_queue = 0;

    time_in_queue = 0.0;
    time_in_server = 0.0;
    
    % 1 for arrival; 2 for departure
    time_next_event(1) = sim_time + exprnd(arrival_mean_time(j+1));
    
    time_next_event(2) = exp(30);
    
    disp(['Launching Simulation...',num2str(j)]);
    
    while(num_clients_count < sim_packets)
        
        min_time_next_event = exp(29);
        type_of_event=0;

        for i=1:num_events
            if(time_next_event(i)<min_time_next_event)
                min_time_next_event = time_next_event(i);
                type_of_event = i;
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
        
        time_in_server = time_in_server + server_status * time_since_last_event;
        
        
        if (type_of_event == 1)
            % -------------------------arrival-------------------------
            num_clients_count = num_clients_count + 1;
            time_next_event(1) = sim_time + exprnd(arrival_mean_time(j+1));

            if(server_status == 1)
                
                num_clients_in_queue = num_clients_in_queue + 1 ;
                
                if(num_clients_in_queue > queue_lim)
                    disp(['queue size = ', num2str(num_clients_in_queue)]);
                    disp(['System Crash at ',num2str(sim_time)]);
                    pause
                end
                                
            else
                
                server_status = 1;
                time_next_event(2) = sim_time + exprnd(service_mean_time);
                
            end
            
        elseif (type_of_event==2)
            
            % ---------------service and departure---------------
            
            if(num_clients_in_queue == 0)
                server_status = 0;
                time_next_event(2) = exp(30);
            else
                
                num_clients_in_queue = num_clients_in_queue - 1;
                
                time_next_event(2) = sim_time + exprnd(service_mean_time);
                
            end
            
        end
        
    end
    
    %results output
    util(j+1) = time_in_server/sim_time;
    avg_num_in_queue(j+1) = time_in_queue/sim_time;
    avg_delay(j+1) = time_in_queue/num_clients_count;
    P(j+1) = service_mean_time./arrival_mean_time(j+1);
    
end

%----------------------graphs--------------------------------
figure('name','Mean Number of Clients in Queue (M/M/1)');
plot(P,avg_num_in_queue,'r',P,P.*P./(1-P),'b');
legend('simulation','theoretical');
title('Mean Number of Clients in Queue (M/M/1)');
xlabel('P');
ylabel('mean number of clients');
axis([0 0.92 0 15]);

figure('name','Mean Delay in Queue (M/M/1)');
plot(P,avg_delay,'r',P,service_mean_time*P./(1-P),'b');
legend('simulation','theoretical');
title('Mean Delay in Queue (M/M/1)');
xlabel('P');
ylabel('mean delay (hrs)');
axis([0 0.92 0 0.15]);

figure('name', 'Utilisation (M/M/1)');
plot(P,util,'r',P,P,'b');
legend('simulation','theoretical');
title('Utilisation (M/M/1)');
xlabel('P');
ylabel('Utilisation');
axis([0 0.92 0 1]);



