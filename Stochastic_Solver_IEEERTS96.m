%%      AUTHORS:    Mirka Mandich, Seattle University
%                   Tianwei Xia, University of Tennessee, Knoxville
%
%       MENTORS:    Dr. Kai Sun, University of Tennessee, Knoxville
%                   Dr. Kevin Tomsovic, University of Tennessee, Knoxville
%
%         TITLE:    Optimal PMU Placement using Stochastic Methods [1]
%
%       PROJECT:    CURENT REU, 2018
%                   Conference Submission for IEEE PES General Meeting, 2018
%
%   DESCRIPTION:    Optimizes locations of PMUs in IEEE Reliability Test System 96 
%                   using stochastic techniques. Considers zero-injection
%                   buses.
%
%    REFERENCES:    [2] http://labs.ece.uw.edu/pstca/rts/pg_tcarts.htm
%                       Table 12 Branch Data, Permanent Outage Duration (DUR)
%
%       UPDATED:    11/6/2018
%%        INPUT:

clc
clear
database = [];

disp('Hello! Welcome to the IEEE-RTS-96 stochastic solver.');
disp(' ');

%confidence interval
disp('What confidence interval for PMU success would you like? (For example: "0.9" ensures 90%.)');
user = input('Enter a value from 0 to 1: ');
if isempty(user)
    user = 0.95;
    disp('Default value used: 0.95');
    disp(' ');
end

%iterations
disp('How many tests would you like to run? (For example: "100".)');
user2 = input('Enter a greater than 10: ');
if isempty(user2)
    user2 = 50;
    disp('Default value used: 50');
    disp(' ');
end

%%    STOCHASTIC:

tb = 73;    %total number of buses
tzib = 40;  %total number of zero-injection buses
tbc = 107;  %total number of bus connections (120, considering the 12 doubles)
tzibc = 99; %total number of zero-injection bus connections

%load probability of branch failures
%duration data [2] has been divided by 8760 to get a percentage of annual time offline
Eta_Failure = zeros(tb); %number of entries: tbc
Eta_Failure(1,2) = 0.0018; Eta_Failure(1,3) = 0.0011; Eta_Failure(1,5) = 0.0011;
Eta_Failure(2,4) = 0.0011; Eta_Failure(2,6) = 0.0011;
Eta_Failure(3,9) = 0.0011; Eta_Failure(3,24) = 0.0877;
Eta_Failure(4,9) = 0.0011;
Eta_Failure(5,10) = 0.0011;
Eta_Failure(6,10) = 0.0040;
Eta_Failure(7,8) = 0.0011; Eta_Failure(7,27) = 0.0011;
Eta_Failure(8,9) = 0.0011; Eta_Failure(8,10) = 0.0011;
Eta_Failure(9,11) = 0.0877; Eta_Failure(9,12) = 0.0877;
Eta_Failure(10,11) = 0.0877; Eta_Failure(10,12) = 0.0877;
Eta_Failure(11,13) = 0.0013; Eta_Failure(11,14) = 0.0013;
Eta_Failure(12,13) = 0.0013; Eta_Failure(12,23) = 0.0013;
Eta_Failure(13,23) = 0.0013; Eta_Failure(13,39) = 0.0013;
Eta_Failure(14,16) = 0.0013;
Eta_Failure(15,16) = 0.0013; Eta_Failure(15,21) = 0.000001; Eta_Failure(15,24) = 0.0013; %double (15,21 is 0.0013^2)
Eta_Failure(16,17) = 0.0013; Eta_Failure(16,19) = 0.0013;
Eta_Failure(17,18) = 0.0013; Eta_Failure(17,22) = 0.0013;
Eta_Failure(18,21) = 0.000001; %double (0.0013^2)
Eta_Failure(19,20) = 0.000001; %double (0.0013^2)
Eta_Failure(20,23) = 0.000001; %double (0.0013^2)
Eta_Failure(21,22) = 0.0013;
Eta_Failure(23,41) = 0.0013;
Eta_Failure(25,26) = 0.0018; Eta_Failure(25,27) = 0.0011; Eta_Failure(25,29) = 0.0011;
Eta_Failure(26,28) = 0.0011; Eta_Failure(26,30) = 0.0011;
Eta_Failure(27,33) = 0.0011; Eta_Failure(27,48) = 0.0877;
Eta_Failure(28,33) = 0.0011;
Eta_Failure(29,34) = 0.0011;
Eta_Failure(30,34) = 0.0040;
Eta_Failure(31,32) = 0.0011;
Eta_Failure(32,33) = 0.0011; Eta_Failure(32,34) = 0.0011;
Eta_Failure(33,35) = 0.0877; Eta_Failure(33,36) = 0.0877;
Eta_Failure(34,35) = 0.0877; Eta_Failure(34,36) = 0.0877;
Eta_Failure(35,37) = 0.0013; Eta_Failure(35,38) = 0.0013;
Eta_Failure(36,37) = 0.0013; Eta_Failure(36,47) = 0.0013;
Eta_Failure(37,47) = 0.0013;
Eta_Failure(38,40) = 0.0013;
Eta_Failure(39,40) = 0.0013; Eta_Failure(39,45) = 0.000001; Eta_Failure(39,48) = 0.0013; %double (39,45 is 0.0013^2)
Eta_Failure(40,41) = 0.0013; Eta_Failure(40,43) = 0.0013;
Eta_Failure(41,42) = 0.0013; Eta_Failure(41,46) = 0.0013;
Eta_Failure(42,45) = 0.000001; %double (0.0013^2)
Eta_Failure(43,44) = 0.000001; %double (0.0013^2)
Eta_Failure(44,47) = 0.000001; %double (0.0013^2)
Eta_Failure(45,46) = 0.0013;
Eta_Failure(49,50) = 0.0018; Eta_Failure(49,51) = 0.0011; Eta_Failure(49,53) = 0.0011;
Eta_Failure(50,52) = 0.0011; Eta_Failure(50,54) = 0.0011;
Eta_Failure(51,57) = 0.0011; Eta_Failure(51,72) = 0.0877;
Eta_Failure(52,57) = 0.0011;
Eta_Failure(53,58) = 0.0011;
Eta_Failure(54,58) = 0.0040;
Eta_Failure(55,56) = 0.0011;
Eta_Failure(56,57) = 0.0011; Eta_Failure(56,58) = 0.0011;
Eta_Failure(57,59) = 0.0877; Eta_Failure(57,60) = 0.0877;
Eta_Failure(58,59) = 0.0877; Eta_Failure(58,60) = 0.0877;
Eta_Failure(59,61) = 0.0013; Eta_Failure(59,62) = 0.0013;
Eta_Failure(60,61) = 0.0013; Eta_Failure(60,71) = 0.0013;
Eta_Failure(62,64) = 0.0013;
Eta_Failure(63,64) = 0.0013; Eta_Failure(63,69) = 0.000001; Eta_Failure(63,72) = 0.0013; %double (63,69 is 0.0013^2)
Eta_Failure(64,65) = 0.0013; Eta_Failure(64,67) = 0.0013;
Eta_Failure(65,66) = 0.0013; Eta_Failure(65,70) = 0.0013;
Eta_Failure(66,69) = 0.000001; %double (0.0013^2)
Eta_Failure(67,68) = 0.000001; %double (0.0013^2)
Eta_Failure(68,71) = 0.000001; %double (0.0013^2)
Eta_Failure(69,70) = 0.0013;
Eta_Failure(21,73) = 0.0013;
Eta_Failure(47,66) = 0.0013;
Eta_Failure(71,73) = 0.0877;

Eta_Failure_Tri = flipud(rot90(Eta_Failure)); %turn upper tri matrix to lower

%convert from failure to success to determine reliability
Eta_Success = zeros(tb);
for r = 1:tb
    for c = 1:tb
        if Eta_Failure_Tri(r, c) ~= 0
            Eta_Success(r, c) = 1-Eta_Failure_Tri(r, c);
        end
    end
end

[row, col] = find(Eta_Failure_Tri); %find location of non-zeros (AKA the bus connections)
for i=1:length(row) %for every connection...
                    % figure();
                    % title(['gaussian distribution data (' num2str(i) ') for branch ' num2str(col(i)) ' to ' num2str(row(i))]);
                    % hold on;
    mu = Eta_Failure_Tri(row(i),col(i));
    r = abs(normrnd(mu,0.05,[1,user2]));
    for j=1:10 %...create monte carlo values
        norm = normpdf(0:.005:1,r(j),0.05);
                    % plot(x,norm)
    end
                    % hold off;
    Eta_Failure_Gaussian(i,:) = r; 
end

[row2, col2] = size(Eta_Failure_Gaussian); %col2 = branch connections; row2 = monte carlo tests (user2)
Eta_Success_Gaussian = zeros(row2, col2);
for r2 = 1:row2
    for c2 = 1:col2
            Eta_Success_Gaussian(r2, c2) = 1-Eta_Failure_Gaussian(r2, c2);
    end
end
%%  OPTIMIZATION:    (ONCE) WITHOUT MONTE CARLO TESTING

%inequality constraints (A*x =< b)
A1 = -Eta_Success+-eye(size(Eta_Success));
A2 = zeros(tb, tzibc);
A2(3,1)   = A1(3,3); %bus 3
A2(24,2)  = A1(24,3);
A2(9,3)   = A1(9,3);
A2(4,4)   = A1(4,4); %bus 4
A2(9,5)   = A1(9,4);
A2(5,6)   = A1(5,5); %bus 5
A2(10,7)  = A1(10,5); 
A2(6,8)   = A1(6,6); %bus 6
A2(10,9)  = A1(10,6); 
A2(8,10)  = A1(8,8); %bus 8
A2(9,11)  = A1(9,8); 
A2(10,12) = A1(10,8); 
A2(9,13)  = A1(9,9); %bus 9
A2(11,14) = A1(11,9); 
A2(12,15) = A1(12,9); 
A2(10,16) = A1(10,10); %bus 10
A2(11,17) = A1(11,10); 
A2(12,18) = A1(12,10); 
A2(11,19) = A1(11,11); %bus 11
A2(13,20) = A1(13,11); 
A2(14,21) = A1(14,11); 
A2(12,22) = A1(12,12); %bus 12
A2(13,23) = A1(13,12); 
A2(23,24) = A1(23,12); 
A2(17,25) = A1(17,17); %bus 17
A2(18,26) = A1(18,17); 
A2(22,27) = A1(22,17); 
A2(19,28) = A1(19,19); %bus 19
A2(20,29) = A1(20,19); %double
A2(20,30) = A1(20,20); %bus 20
A2(23,31) = A1(23,20); %double 
A2(24,32) = A1(24,24); %bus 24
A2(27,33) = A1(27,27); %bus 27
A2(33,34) = A1(33,27); 
A2(48,35) = A1(48,27); 
A2(28,36) = A1(28,28); %bus 28
A2(33,37) = A1(33,28); 
A2(29,38) = A1(29,29); %bus 29
A2(34,39) = A1(34,29); 
A2(30,40) = A1(30,30); %bus 30
A2(34,41) = A1(34,30); 
A2(32,42) = A1(32,32); %bus 32
A2(33,43) = A1(33,32); 
A2(34,44) = A1(34,32); 
A2(33,45) = A1(33,33); %bus 33
A2(35,46) = A1(35,33); 
A2(36,47) = A1(36,33); 
A2(34,48) = A1(34,34); %bus 34
A2(35,49) = A1(35,34); 
A2(36,50) = A1(36,34); 
A2(35,51) = A1(35,35); %bus 35
A2(37,52) = A1(37,35); 
A2(38,53) = A1(38,35); 
A2(36,54) = A1(36,36); %bus 36
A2(37,55) = A1(37,36); 
A2(47,56) = A1(47,36); 
A2(41,57) = A1(41,41); %bus 41
A2(42,58) = A1(42,41); 
A2(46,59) = A1(46,41); 
A2(43,60) = A1(43,43); %bus 43
A2(44,61) = A1(44,43); %double 
A2(44,62) = A1(44,44); %bus 44 
A2(47,63) = A1(47,44); %double
A2(48,64) = A1(48,48); %bus 48
A2(51,65) = A1(51,51); %bus 51
A2(57,66) = A1(57,51); 
A2(72,67) = A1(72,51); 
A2(52,68) = A1(52,52); %bus 52
A2(57,69) = A1(57,52); 
A2(53,70) = A1(53,53); %bus 53
A2(58,71) = A1(58,53); 
A2(54,72) = A1(54,54); %bus 54
A2(58,73) = A1(58,54); 
A2(56,74) = A1(56,56); %bus 56
A2(57,75) = A1(57,56); 
A2(58,76) = A1(58,56); 
A2(57,77) = A1(57,57); %bus 57
A2(59,78) = A1(59,57); 
A2(60,79) = A1(60,57); 
A2(58,80) = A1(58,58); %bus 58
A2(59,81) = A1(59,58); 
A2(60,82) = A1(60,58); 
A2(59,83) = A1(59,59); %bus 59
A2(61,84) = A1(61,59); 
A2(62,85) = A1(62,59); 
A2(60,86) = A1(60,60); %bus 60
A2(61,87) = A1(61,60); 
A2(71,88) = A1(71,60); 
A2(65,89) = A1(65,65); %bus 65
A2(66,90) = A1(66,65); 
A2(70,91) = A1(70,65); 
A2(67,92) = A1(67,67); %bus 67
A2(68,93) = A1(68,67); %double
A2(68,94) = A1(68,68); %bus 68
A2(71,95) = A1(71,68); %double
A2(72,96) = A1(72,72); %bus 72
A2(73,97) = A1(73,73); %bus 73
A2(21,98) = A1(21,73); 
A2(71,99) = A1(71,73); 
A = [A1 A2];
b = -(ones(1,tb))'*user; %our confidence interval

%equality constraints (Aeq*x = beq); zero-injection
Aeq1 = zeros(tzib,tb);
Aeq2 = [                1 1 1   zeros(1,96);
            zeros(1,3)  1 1     zeros(1,94);
            zeros(1,5)  1 1     zeros(1,92);
            zeros(1,7)  1 1     zeros(1,90);
            zeros(1,9)  1 1 1   zeros(1,87);
            zeros(1,12) 1 1 1   zeros(1,84);
            zeros(1,15) 1 1 1   zeros(1,81);
            zeros(1,18) 1 1 1   zeros(1,78);
            zeros(1,21) 1 1 1   zeros(1,75);
            zeros(1,24) 1 1 1   zeros(1,72);
            zeros(1,27) 1 1     zeros(1,70);
            zeros(1,29) 1 1     zeros(1,68);
            zeros(1,31) 1       zeros(1,67);
            zeros(1,32) 1 1 1   zeros(1,64);
            zeros(1,35) 1 1     zeros(1,62);
            zeros(1,37) 1 1     zeros(1,60);
            zeros(1,39) 1 1     zeros(1,58);
            zeros(1,41) 1 1 1   zeros(1,55);
            zeros(1,44) 1 1 1   zeros(1,52);
            zeros(1,47) 1 1 1   zeros(1,49);
            zeros(1,50) 1 1 1   zeros(1,46);
            zeros(1,53) 1 1 1   zeros(1,43);
            zeros(1,56) 1 1 1   zeros(1,40);
            zeros(1,59) 1 1     zeros(1,38);
            zeros(1,61) 1 1     zeros(1,36);
            zeros(1,63) 1       zeros(1,35);
            zeros(1,64) 1 1 1   zeros(1,32);
            zeros(1,67) 1 1     zeros(1,30);
            zeros(1,69) 1 1     zeros(1,28);
            zeros(1,71) 1 1     zeros(1,26);
            zeros(1,73) 1 1 1   zeros(1,23);
            zeros(1,76) 1 1 1   zeros(1,20);
            zeros(1,79) 1 1 1   zeros(1,17);
            zeros(1,82) 1 1 1   zeros(1,14);
            zeros(1,85) 1 1 1   zeros(1,11);
            zeros(1,88) 1 1 1   zeros(1,8);
            zeros(1,91) 1 1     zeros(1,6);
            zeros(1,93) 1 1     zeros(1,4);
            zeros(1,95) 1       zeros(1,3);
            zeros(1,96) 1 1 1               ];
Aeq = [Aeq1 Aeq2];
beq = ones(1,tzib); %because all zero-injection buses have to equal 1

f = [ones(1,tb) zeros(1,tzibc)]; %optimizing f for cost only
intcon = 1:(tb+tzibc);      %all must be integers
lb = zeros(1,(tb+tzibc));   %enforces binary
ub = ones(1,(tb+tzibc));    %enforces binary

[x,fval] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);

disp(x) %displays a PMU configuration which maintains full observability with optimal cost
disp(sum(x)); %total number of PMUs in setup

%%  OPTIMIZATION:   WITH MONTE CARLO TESTING

[row3, col3] = size(Eta_Success_Gaussian);
[row4, col4] = size(Eta_Success);
pmu = [];

for c3 = 1:col3 %run user2 times
    r3 = 1;
    for r4 = 1:row4
        for c4 = 1:col4
            if Eta_Success(r4, c4) ~= 0 %if there's a connection...
                Eta_Success(r4, c4) = Eta_Success_Gaussian(r3, c3); %...replace with monte carlo...
                r3 = r3+1; %...and move onto the next
            end
        end
    end

    A1 = -Eta_Success+-eye(size(Eta_Success));
    A2 = zeros(tb, tzibc);
    A2(3,1)   = A1(3,3); %bus 3
    A2(24,2)  = A1(24,3);
    A2(9,3)   = A1(9,3);
    A2(4,4)   = A1(4,4); %bus 4
    A2(9,5)   = A1(9,4);
    A2(5,6)   = A1(5,5); %bus 5
    A2(10,7)  = A1(10,5); 
    A2(6,8)   = A1(6,6); %bus 6
    A2(10,9)  = A1(10,6); 
    A2(8,10)  = A1(8,8); %bus 8
    A2(9,11)  = A1(9,8); 
    A2(10,12) = A1(10,8); 
    A2(9,13)  = A1(9,9); %bus 9
    A2(11,14) = A1(11,9); 
    A2(12,15) = A1(12,9); 
    A2(10,16) = A1(10,10); %bus 10
    A2(11,17) = A1(11,10); 
    A2(12,18) = A1(12,10); 
    A2(11,19) = A1(11,11); %bus 11
    A2(13,20) = A1(13,11); 
    A2(14,21) = A1(14,11); 
    A2(12,22) = A1(12,12); %bus 12
    A2(13,23) = A1(13,12); 
    A2(23,24) = A1(23,12); 
    A2(17,25) = A1(17,17); %bus 17
    A2(18,26) = A1(18,17); 
    A2(22,27) = A1(22,17); 
    A2(19,28) = A1(19,19); %bus 19
    A2(20,29) = A1(20,19); %double
    A2(20,30) = A1(20,20); %bus 20
    A2(23,31) = A1(23,20); %double 
    A2(24,32) = A1(24,24); %bus 24
    A2(27,33) = A1(27,27); %bus 27
    A2(33,34) = A1(33,27); 
    A2(48,35) = A1(48,27); 
    A2(28,36) = A1(28,28); %bus 28
    A2(33,37) = A1(33,28); 
    A2(29,38) = A1(29,29); %bus 29
    A2(34,39) = A1(34,29); 
    A2(30,40) = A1(30,30); %bus 30
    A2(34,41) = A1(34,30); 
    A2(32,42) = A1(32,32); %bus 32
    A2(33,43) = A1(33,32); 
    A2(34,44) = A1(34,32); 
    A2(33,45) = A1(33,33); %bus 33
    A2(35,46) = A1(35,33); 
    A2(36,47) = A1(36,33); 
    A2(34,48) = A1(34,34); %bus 34
    A2(35,49) = A1(35,34); 
    A2(36,50) = A1(36,34); 
    A2(35,51) = A1(35,35); %bus 35
    A2(37,52) = A1(37,35); 
    A2(38,53) = A1(38,35); 
    A2(36,54) = A1(36,36); %bus 36
    A2(37,55) = A1(37,36); 
    A2(47,56) = A1(47,36); 
    A2(41,57) = A1(41,41); %bus 41
    A2(42,58) = A1(42,41); 
    A2(46,59) = A1(46,41); 
    A2(43,60) = A1(43,43); %bus 43
    A2(44,61) = A1(44,43); %double 
    A2(44,62) = A1(44,44); %bus 44 
    A2(47,63) = A1(47,44); %double
    A2(48,64) = A1(48,48); %bus 48
    A2(51,65) = A1(51,51); %bus 51
    A2(57,66) = A1(57,51); 
    A2(72,67) = A1(72,51); 
    A2(52,68) = A1(52,52); %bus 52
    A2(57,69) = A1(57,52); 
    A2(53,70) = A1(53,53); %bus 53
    A2(58,71) = A1(58,53); 
    A2(54,72) = A1(54,54); %bus 54
    A2(58,73) = A1(58,54); 
    A2(56,74) = A1(56,56); %bus 56
    A2(57,75) = A1(57,56); 
    A2(58,76) = A1(58,56); 
    A2(57,77) = A1(57,57); %bus 57
    A2(59,78) = A1(59,57); 
    A2(60,79) = A1(60,57); 
    A2(58,80) = A1(58,58); %bus 58
    A2(59,81) = A1(59,58); 
    A2(60,82) = A1(60,58); 
    A2(59,83) = A1(59,59); %bus 59
    A2(61,84) = A1(61,59); 
    A2(62,85) = A1(62,59); 
    A2(60,86) = A1(60,60); %bus 60
    A2(61,87) = A1(61,60); 
    A2(71,88) = A1(71,60); 
    A2(65,89) = A1(65,65); %bus 65
    A2(66,90) = A1(66,65); 
    A2(70,91) = A1(70,65); 
    A2(67,92) = A1(67,67); %bus 67
    A2(68,93) = A1(68,67); %double
    A2(68,94) = A1(68,68); %bus 68
    A2(71,95) = A1(71,68); %double
    A2(72,96) = A1(72,72); %bus 72
    A2(73,97) = A1(73,73); %bus 73
    A2(21,98) = A1(21,73); 
    A2(71,99) = A1(71,73); 
    A = [A1 A2];

    [x,fval] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);
    
    disp(x); %displays a PMU configuration which maintains full observability with optimal cost
    pmu = [pmu, sum(x)];
end

%%        OUTPUT:

%print results (the number of PMUs determined for each configuration)
disp(pmu);

%graph results
figure();
bar(1:user2, pmu, 'FaceColor', [0.8 0.9 0.8], 'EdgeColor', [0.5 0.9 0.5]);
xlabel(['Results of ' num2str(user2) ' Simulations']);
ylabel('Total PMUs Required');
grid on;
title({'Optimal PMU Placement for IEEE RTS-96';['Confidence Interval: ' num2str(user) ' | Average PMUs Required: ' num2str(ceil(mean(pmu)))]});
hold on;
plot(xlim,[mean(pmu) mean(pmu)], 'r');
axis([0 user2+1 ceil(mean(pmu))-5 ceil(mean(pmu))+4]);

%print results summary
disp(['PMUs needed, on average = ' num2str(mean(pmu))]);
