bucket=telemetry-parquet

# sbt assembly
for date in 20161004 20161009 20161016 20161017 20161022 20161029 20161105 20161112 20161119 20161126 20161203 20161210 20161217 20161224 20161231 20170107 20170114 20170121 20170128 20170204; do
    echo "STARTING $date ====================================================="
    aws s3 rm --recursive s3://telemetry-parquet/cross_sectional/v${date}
    aws s3 rm "s3://telemetry-parquet/cross_sectional/v${date}_\$folder\$"
    spark-submit --executor-cores 8 \
        --conf spark.memory.useLegacyMode=true \
        --conf spark.storage.memoryFraction=0 \
        --master yarn \
        --deploy-mode client \
        --class com.mozilla.telemetry.views.CrossSectionalView \
        target/scala-2.11/telemetry-batch-view-1.1.jar \
        --outName "v$date" \
        --outputBucket $bucket 
        #--localTable s3://telemetry-parquet/longitudinal/v$date/
    if [ $? -ne 0 ]
    then
        break
    fi
done
