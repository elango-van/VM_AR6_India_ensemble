


models <- c('ACCESS-CM2','ACCESS-ESM1-5','BCC-CSM2-MR','CanESM5','EC-Earth3','EC-Earth3-Veg','INM-CM4-8','INM-CM5-0','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0','NorESM2-LM','NorESM2-MM')
scenarious <- c('ssp126','ssp245','ssp370','ssp585')
parameters <- c('PrecipData_merged')

scrfolder <- 'H:/AR6/India'
outrootfolder <- 'H:/AR6/India/ensumble'

ifelse(!file.exists(outrootfolder),dir.create(outrootfolder),file.exists(outrootfolder))

maxlength <- 54787

for(scenario in scenarious){

	sceoutfolder <- file.path(outrootfolder,scenario);
	ifelse(!file.exists(sceoutfolder),dir.create(sceoutfolder),file.exists(sceoutfolder))

	for(parameter in parameters){

		prmoutfolder <- file.path(sceoutfolder,parameter);
		ifelse(!file.exists(prmoutfolder),dir.create(prmoutfolder),file.exists(prmoutfolder))

		somefolder <- file.path(scrfolder,models[1],scenario,parameter)
		files <- list.files(somefolder,"*.txt")
		for(filename in files){

			ensumblefilename <-file.path(prmoutfolder,basename(filename))
			if(file.exists(ensumblefilename)) next

			rm(dataset,startyear)
			for(model in models){
				ensfilename <- file.path(scrfolder,model,scenario,parameter,filename)
				print(ensfilename)
				data <- read.delim(ensfilename,sep=',',header=T,stringsAsFactors=F)
				startyear<- sub('X','',colnames(data))
				##data<-as.vector(data[,1])
				if(!exists('dataset')){
					dataset<-data.frame(data)
					colnames(dataset)<- basename(ensfilename)
				} else {
					pvrlength<-dim(dataset)[1]
					currlength<-dim(data)[1]
					if(pvrlength > currlength){
						norow<-(pvrlength-currlength)
						data<-rbind(data,tail(data,norow))
					}
					colnames(data)<- basename(ensfilename)
					dataset<-cbind(dataset,data)
					rm(pvrlength,currlength,data)
				}
			}
			ensumble<- data.frame(rowMeans(dataset,na.rm=T))
			ensumble<- sprintf('% 5g',round(ensumble[,1],1))
			ensumble<- append(startyear,ensumble)
			

			write.table(ensumble, ensumblefilename, append = FALSE, quote = F, sep = "\t", row.names = F,col.names = F)
			rm(ensumble, ensumblefilename, data)
		}
	}
}

print('Completed')



