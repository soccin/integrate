Rscript integrate/starmap/bicMapToSTARMap.R ../meta/Proj_17297_sample_mapping.txt
cat Proj_17297_star_manifest.txt  | xargs -n 3 bsub -o LSF/ -J STARf -n 18 -W 12:00 ./integrate/starmap/starAlignFusion.sh 
#
# Create intergrate manifest
# Path,SampleID,Type[T,N,R]
#
Rscript integrate/makeIntegrateProjectFile.R bams

#
# 3 if no mathced normal, 4 if T/N WGS pairs
#
cat _integrate_manifest.tsv | xargs -n 3,4 bsub -o LSF/ -n 12 -R "rusage[mem=12]" -R cmorsc1 -W 24:00 ./integrate/integrateFusionCalls.sh
