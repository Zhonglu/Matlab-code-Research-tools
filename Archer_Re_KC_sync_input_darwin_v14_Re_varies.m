%makeinput_v11_auto_copyall_SBATCH_remesh_input_mass_ratio

%this version can deal with damping ratio
%clc
warning('off','all')
clear all
close all
fclose all;
cd('/Users/zhonglulin/Documents/OneDrive - University Of Cambridge/OneDrive/PhDWorks/VIV')

copyall_or_not=1; 
zip_or_not=0;
ttperiods=5000;
walltime='24:00:00'; %Wall clock time Archer standard max: 24, Darwin max: 12 hours.

% 5 cases at a time recommended on Archer

codename='7'; % 7 for with spring, 8 for free cylinder 

%account='SOGA';% zl352
%account='LIANG-SL4';%dl359 xz328 fy hj

ristart=9339;%;
ri=ristart-1;
s=0;
%%{
if1=[
    00.050
    00.100
    00.150
    00.200
    00.250
    00.300
    00.350
    00.360
    00.370
    00.380
    00.390
    00.400
    00.410
    00.420
    00.430
    00.440
    00.450
    00.500
    00.550
    00.600
    00.645
    00.650
    00.655
    00.660
    00.665
    00.670
    00.675
    00.680
    00.685
    00.690
    00.695
    00.700
    00.705
    00.710
    00.715
    00.720
    00.725
    00.730
    00.735
    00.740
    00.745
    00.750
    00.755
    00.760
    00.765
    00.770
    00.775
    00.780
    00.785
    00.790
    00.795
    00.800
    0.8050
    0.8100
    00.824
    0.8150
    0.8200
    00.825
    00.850
    00.900
    00.950
    01.000
    01.100
    01.200
    01.300
    01.400
    01.600
    01.800
    02.000
    02.400
    2.8
    3.2
    ]';
nfarm=ceil(length(if1)/24); % Archer has 24 cores per node

if copyall_or_not==0; mkdir smallversion; cd smallversion; end
if copyall_or_not==1; mkdir largeversion; cd largeversion; end
%re=100;% Reynolds Number
for sn=1:1
    
    if sn==1
        ristart2=ristart;
    else
        ristart2=ri+1;
    end
    
    if sn==1 %A1 varies
        gii=[
% 0.3 %9326
% 0.4 %9327
% 0.5 %9328
% 0.572957795 %9329
% 0.7 %9330
% 0.716197244 %9331
% 0.954929658%9332
% 1.074295866%9333
% 1.193662073%9334
% 1.480140971%9335
% 1.7 %9336
% 1.7 %9337
% 1.695000144
2
2
]';
        aii=[
% 0.127323954
% 0.190985932
% 0.254647909
% 0.381971863
% 0.429718346
% 0.477464829
% 0.636619772
% 0.716197244
% 0.795774715
% 0.986760647
% 1.03450713
% 1.082253613
% 1.130000096
1.177746579
1.225493062
            ]';
        
        reii=[
% 88
% 132
% 176
% 264
% 297
% 330
% 440
% 495
% 550
% 682
% 715
% 748
% 781
814
847
            ]';
        mii=[1.5];
        dampii=[0.00];
    end
    
    clear txt
    qsubstr='';
    for itemp=1:nfarm
        qsubstr=[qsubstr,' qsub taskfarm',num2str(itemp),'.pbs;'];
    end
    clear itemp
    %for gi=gii
        
        for mi=mii
            for dampi=dampii
                
                for igar=1:length(aii)
                    if length(aii)~=length(reii)
                        stop%
                    end
                    %for ai=aii
                    %for rei=reii
                    gi=gii(igar);
                    ai=aii(igar);
                    rei=reii(igar);
                    ri=ri+1;
                    [ttt1,ttt2,ttt3]=rmdir(['*r',num2str(ri)],'s'); % remove the old input files
                    temp1=['g',num2str(gi,'%.1f'),...
                        'a',num2str(ai,'%.3f'), ...
                        'm',num2str(mi,'%.1f'),...
                        'd',num2str(dampi,'%.2f'),...
                        'e',num2str(rei,'%.1f'),...
                        'r',num2str(ri)];
                    mkdir(temp1)
                    disp(temp1)
                    
                    
                    s=s+1;
                    txt{s}=['cd ./*r',num2str(ri),'; chmod u+x suball.com; ./suball.com; cd ../']; %For darwin
                    txt2{s}=['cd ./*r',num2str(ri),'; chmod u+x task*; chmod u+x cpuid.x;',qsubstr,' cd ../']; %For Archer
                end
            end
        end
    %end
    
    
    disp('===1st level folders created===')
    
    %% for Darwin, write job submit file
    fid = fopen(['./d',num2str(ristart2),'_to_',num2str(ri),'_subauto_Darwin'], 'w');
    for iit = 1:length(txt)
        fprintf(fid,'%s\n', txt{iit});
    end
    clear txt
    %% for Archer, write job submit file
    fid = fopen(['./a',num2str(ristart2),'_to_',num2str(ri),'_subauto_Archer'], 'w');
    for iit = 1:length(txt2)
        fprintf(fid,'%s\n', txt2{iit});
    end
    clear txt2 iit
end

%%
start_task_num=ristart;
end_task_num=ri;%117+18-1;

nn=end_task_num-start_task_num+1;
for ii=1:nn
    task_num=start_task_num+ii-1;
    folderlist=dir(['*r',num2str(task_num)]);
    foldername=folderlist.name;
    disp(foldername)
    
    %Global Calculation parameters
    
    odfis=2000;% Output data frequency in steps
    misfve=12000;% Maximum iteration step for velocity equation
    misfppe=10000;% Maximum iteration step for Pressure Possion equation
    NITRB= '350';       % MAXIMUM ITERATION STEP FOR MESH UPDATE EUQATION
    AERB = '1.D-15';      % ALLOW ERROR FOR SOLVING THE MESH UPDATE EQUATION
    % NITRB= '350'; By convention
    % AERB = '1.D-15'; By convention

    %% INPUT PARAMETERs 1
    gam=s2gamr(foldername);
    g=gam(1);%G/D
    a1=gam(2);%A1
    m=gam(3);%m*
    damp=gam(4);%damp ratio
    re=gam(5); %Renolds Number
    ftspara=0.001;%normally 0.00025 for interaction of two cylinders when 0.001 courant=0.76
    taskstr=['r',num2str(gam(end))]        ;%task number
    

    %% ziping file
    if mod(ii,5)==1; rstr1=num2str(gam(end));clear zipped;iz=1;end
    zipped{iz}=['*',taskstr];iz=iz+1;
    
    %% account
    %if ii<=20; continue;end
    if ii<=5
        account='e556-wm280';% e556-zl352 (Archer dring test)
    elseif ii<=10
        account='e556-hcjh2';
    elseif ii<=15
        account='e556-yz445';
    elseif ii<=20
        account='e556-lf368';
    else
        disp('ATTENTION! need more accounts! continue to use Darwin Accounts');%pause
        account='SOGA';
        walltime='12:00:00';
    end
    %% Adjust Title Format
    gstr=num2str(g,'%.2f');%    ,'%.3f'
    a1str=num2str(a1,'%.3f');%  ,'%.3f'
    mstr=num2str(m);%,'%.1f'
    dampstr=num2str(damp,'%.3f');
    restr=num2str(re,'%.1f');
    
    protodir=['/Users/zhonglulin/Documents/OneDrive - University Of Cambridge/OneDrive/PhDWorks/VIV/Chosen_mesh_19_Dec/g',num2str(g,'%.1f')];
    
    
    %% =============================FOLDERs====================== f1s to be run
    cd (foldername)
    %---
    i=0;
    j=0;
    s=0;
    clear txt
    %% j=if1
    for j=if1
        %for j=[0.81:0.01:0.99]
        %if j==0.85||j==0.90||j==0.95
        %continue
        %end
        name=['0',num2str(j,'%05.3f'),''];
        mkdir(name)
        %end
        s=s+1;
        txt{s}=['cd ./',name,'; qsub slurm_submit.txt; cd ../'];
    end
    %% write suball.com file
    fid = fopen(['./suball.com'], 'w');
    for iit = 1:length(txt)
        fprintf(fid,'%s\n', txt{iit});
    end
    disp('folder created')
    %%
    
    
    
    %% =============================COPY1======================
    
    if copyall_or_not
        
        disp('copying from proto...')
        
        origindir=pwd;
        
        cd (protodir)
        list1=dir('*.TXT');
        n1=length(list1);
        
        cd (origindir)
        list0=dir('0*');
        n0=length(list0);
        
        %%
        %n0=3;%for test
        %% cp txt
        for j=1:n0
            for i=1:n1
                origin=[protodir,'/',list1(i).name];
                destin=['./',list0(j).name];
                copyfile(origin,destin)
            end
            %copy Archer utilities
        end
        
        
        
        
        %% =============================COPY2======================
        %%
        %n0=3;%for test
        %%
        %     for j=1:n0
        %         for i=1:n1
        %             origin=['./proto/',list1(i).name];
        %             destin=['./',list0(j).name];
        %             copyfile(origin,destin)
        %         end
        %     end
        %     disp('copy done')
        
        %% ===========================
    end % end of copy
    %% cp Archer relevent
    copyfile('/Users/zhonglulin/Documents/OneDrive - University Of Cambridge/OneDrive/PhDWorks/VIV/Chosen_mesh_19_Dec/task*','./')
    copyfile('/Users/zhonglulin/Documents/OneDrive - University Of Cambridge/OneDrive/PhDWorks/VIV/Chosen_mesh_19_Dec/cpuid.x','./')
    %%
    disp('copy done')
    %% =============================EDIT======================
    %clear all
    %close all
    
    list0=dir('0*');
    n0=length(list0);
    
    %n0=3;%test f=0.05
    
    
    
    %%
    disp(['alter value for ','G/D=',gstr,', A1=',a1str,', m*=',mstr,' damp=',dampstr,' re=',restr])
    
    %% Write Archer .PBS
    for ifa=1:nfarm
        fid = fopen('taskfarm.pbs','r');
        i = 1;
        tline = fgetl(fid);
        txtp{i} = tline;
        while ischar(tline)
            i = i+1;
            tline = fgetl(fid);
            txtp{i} = tline;
        end
        fclose(fid);
        
        % Change cell
        txtp{2} = ['#PBS -N ','r',num2str(gam(end)),'fa',num2str(ifa)];
        txtp{4} = ['#PBS -l walltime=',walltime];
        txtp{5} = ['#PBS -A ',account];
        txtp{18} = ['aprun -n ${CORES_PER_NODE} -cc 0:1:2:3:4:5:6:7:8:9:10:11:12:13:14:15:16:17:18:19:20:21:22:23 task',num2str(ifa),'.sh'];
        
        % write
        fid = fopen(['taskfarm',num2str(ifa),'.pbs'], 'w'); % e.g. taskfarm1.pbs
        for i = 1:numel(txtp)
            if txtp{i+1} == -1
                fprintf(fid,'%s', txtp{i});
                break
            else
                fprintf(fid,'%s\n', txtp{i});
            end
        end
        clear txtp
        
        
        %% Write Archer .sh
        fid = fopen('task.sh','r');
        i = 1;
        tline = fgetl(fid);
        txtp{i} = tline;
        while ischar(tline)
            i = i+1;
            tline = fgetl(fid);
            txtp{i} = tline;
        end
        fclose(fid);
        % Change cell
        txtp{18} = ['cd ${folders[taskindex-1+',num2str((ifa-1)*24),']}'];
        txtp{19} = ['/work/e556/e556/$USER/scratch/code7/viv > ${taskindex}.out 2> ${taskindex}.err'];
        % write
        fid = fopen(['task',num2str(ifa),'.sh'], 'w'); % e.g. taks1.sh
        for i = 1:numel(txtp)
            if txtp{i+1} == -1
                fprintf(fid,'%s', txtp{i});
                break
            else
                fprintf(fid,'%s\n', txtp{i});
            end
        end
        clear txtp
    end
    delete task.sh
    delete taskfarm.pbs
    
    
    for j=1:n0
        %% Calculated INPUT PARAMETERs
        %disp(['alter value for ','G/D=',num2str(g),', A1=',num2str(a1),', m*=',num2str(m), ...,
        %    ' f1=',list0(j).name])
        f1=str2num(list0(j).name);
        visc=2*3.14159265*f1*a1/re; %viscosity
        fts=ftspara/(2*3.14159265*a1*f1); %flow time step
        
        tts=floor(ttperiods/f1/fts);% total time step
        
        
        f1str=list0(j).name;
        taskname=['f',f1str,taskstr];
        %taskdirdarwin=['cd /home/zl352/VIVHPC/','g',gstr,'a',a1str,'m',mstr,'zl_',taskstr,'_code',codename,'/',list0(j).name];
        %taskdirorange=['cd /projects/y73/dongfang/','g',gstr,'a',a1str,'m',mstr,'zl_',taskstr,'_code',codename,'/',list0(j).name];
        %taskdirdarwin=['cd ~/scratch/','g',gstr,'a',a1str,'m',mstr,'zl_',taskstr,'/',list0(j).name];
        taskdirdarwin='cd $workdir';
        taskdirorange=['Not in use: cd /projects/y73/dongfang/','g',gstr,'a',a1str,'m',mstr,'zl_',taskstr,'/',list0(j).name];
        %%   Reading and edit txt
        %
        origindir=pwd;
        cd (protodir)
        fid = fopen('VIV_PARA.TXT','r');
        i = 1;
        tline = fgetl(fid);
        txtv{i} = tline;
        while ischar(tline)
            i = i+1;
            tline = fgetl(fid);
            txtv{i} = tline;
        end
        fclose(fid);
        
        % Change cell
        txtv{3} = [strrep(sprintf('%d',a1),'e','D'),'    -> amplitude of the forced vibration'];
        txtv{4} = [strrep(sprintf('%d',f1),'e','D'),'    -> frequency (1/period) of the forced vibration'];
        txtv{9} = [mstr,'   -> mass ratio'];
        txtv{11} = [dampstr,'   -> damping factor of cylinder 2'];
        %
        %%
        fid = fopen('CALCULATION_PARA.TXT','r');
        i = 1;
        tline = fgetl(fid);
        txtc{i} = tline;
        while ischar(tline)
            i = i+1;
            tline = fgetl(fid);
            txtc{i} = tline;
        end
        fclose(fid);
        
        % Change cell
        txtc{1} = [strrep(sprintf('%d',visc),'e','D'),'       --> viscosity'];
        txtc{2} = [strrep(sprintf('%d',fts),'e','D'),'       --> FLOW TIME STEP'];
        txtc{4} = [num2str(tts),'         --> Total time steps'];
        txtc{5} = [num2str(odfis),'         --> Output data frequency in steps'];
        txtc{7} = [num2str(misfve),'         --> Maximum iteration step for velocity equation'];
        txtc{10} = [num2str(misfppe),'         --> Maximum iteration step for Pressure Possion equation'];
        txtc{14} = [NITRB,'         --> MAXIMUM ITERATION STEP FOR MESH UPDATE EUQATION '];
        txtc{15} = [AERB,'         --> ALLOW ERROR FOR SOLVING THE MESH UPDATE EQUATION'];
        
        %% SLURM
        fid = fopen('slurm_submit.txt','r');
        i = 1;
        tline = fgetl(fid);
        txts{i} = tline;
        while ischar(tline)
            i = i+1;
            tline = fgetl(fid);
            txts{i} = tline;
        end
        fclose(fid);
        
        % Change cell
        
        txts{13} = ['#SBATCH -J ',taskname];
        txts{15} = ['#SBATCH -A ',account];
        txts{21} = ['#!SBATCH --mem=200'];
        txts{24} = ['#SBATCH --time=',walltime];
        txts{25} = ['#SBATCH --mail-user=zl352'];
        txts{26} = ['#SBATCH --mail-type=END'];
        %txts{63} = ['application="/home/zl352/VIVHPC/code',codename,'/viv"']; %code dir
        txts{63} = ['application="~/scratch/code',codename,'/viv"']; %code dir
        txts{107} = taskdirdarwin;     %running dir
        %txts{107} = 'cd $workdir';
        
        %% orange PBS
        fid = fopen('pbs.sh','r');
        i = 1;
        tline = fgetl(fid);
        txtp{i} = tline;
        while ischar(tline)
            i = i+1;
            tline = fgetl(fid);
            txtp{i} = tline;
        end
        fclose(fid);
        
        % Change cell
        txtp{3} = ['#PBS -l walltime=',walltime];
        txtp{6} = ['#PBS -N ',taskname];
        txtp{7} = taskdirorange;
        txtp{8} = ['/projects/y73/dongfang/code',codename,'/viv > test.e'];
        
        
        %%  write txt
        cd (origindir)
        cd (list0(j).name)
        fid = fopen('VIV_PARA.TXT', 'w');
        for i = 1:numel(txtv)
            if txtv{i+1} == -1
                fprintf(fid,'%s', txtv{i});
                break
            else
                fprintf(fid,'%s\n', txtv{i});
            end
        end
        
        fid = fopen('CALCULATION_PARA.TXT', 'w');
        for i = 1:numel(txtc)
            if txtc{i+1} == -1
                fprintf(fid,'%s', txtc{i});
                break
            else
                fprintf(fid,'%s\n', txtc{i});
            end
        end
        
        fid = fopen('slurm_submit.txt', 'w');
        for i = 1:numel(txts)
            if txts{i+1} == -1
                fprintf(fid,'%s', txts{i});
                break
            else
                fprintf(fid,'%s\n', txts{i});
            end
        end
        
        fid = fopen('pbs.sh', 'w');
        for i = 1:numel(txtp)
            if txtp{i+1} == -1
                fprintf(fid,'%s', txtp{i});
                break
            else
                fprintf(fid,'%s\n', txtp{i});
            end
        end
        %%
        fclose(fid);
        cd ('../')
    end
    cd ('../')
    
    %% zipping files
    if mod(ii,5)==0
        rstr2=num2str(gam(end));
        if zip_or_not
            zip([rstr1,'_to_',rstr2,'_',account],zipped,'./')
        end
        %zip('../thesis.zip',{'thesis.doc','defense.ppt'},'.');
        %disp('pause for you to copy the zip file!');pause;
    end
    %clear rstr1 rstr2
    %% Notes
    disp('====================================')
    disp(pwd)
    disp(['NOTE! acount: ',account])
    disp(['NOTE! Output step ',num2str(odfis)])
    disp(['NOTE! codename= ',codename])
    disp(['NOTE! flow_time_step_para= ',num2str(ftspara)])
    disp(['NOTE! taskdir_darwin= ',taskdirdarwin])
    %disp(['NOTE! taskdir_orange= ',taskdirorange])
    disp(['NOTE! walltime= ', walltime])
    disp('====================================')
    fclose all;
end



if copyall_or_not==0; cd ../; end