function y=A2eu(G,A1,mr,f1)
     %A2 = A1.*( 0.0404610726917864..*f1 + 3.22417005702081..*f1...^(f1...^ (-2.98185247109963..*mr))../ (G + 6.24655536070865..*A1 + (4.88046768088561 + 23.0910663472393..*G)..^f1..*( f1...^(f1...^(-2.98185247109963..*mr)))...^(mr./f1...^(f1...^(-2.98185247109963..*mr)))));
            y = A1.* (0.0410712276225994.*f1 + 3.12135534754373.*f1.^(f1.^(-3.12509563952794.*mr))./(G + 14.3334258840871.*A1.*f1.^(f1.^(-3.12509563952794.*mr)) + (3.84756680693061 + 23.6286911002874.*G).^f1.*(f1.^(f1.^(-3.12509563952794.*mr))).^(mr./f1.^(f1.^(-3.12509563952794.*mr)))));
            %A2 = 0.0275211883574247.*A1 + 2.53134056832888.*A1.*exp(-1.32694982349777.*G).*gauss(0.143917202827626./f1.^(G + 4.18052201098028.*mr + 0.0330672548540617./A1) - 1.55135322591415);