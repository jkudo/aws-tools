#/bin/bash
LOGNAME="exportl_flowlog.csv"
LOGGROUP="flowloggroup"
LOGSTREAM="logstreamname"

aws logs describe-log-streams --log-group-name $LOGGROUP | jq -r ".logStreams[] | .logStreamName" > $LOGSTREAM
echo 'date,version,account-id,interface-id,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes,start,end,action,log-status' > $LOGNAME
count=1
cat $LOGSTREAM | while read LINE;do
	aws logs get-log-events --log-group-name $LOGGROUP --log-stream-name $LINE  | jq .events[] | jq -r "[.timestamp, .message] | @csv" | sed 's/"//g' | sed 's/000,/ /g' | awk '{print strftime("%Y/%m/%d+%H:%M:%S",$1),$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,strftime("%Y/%m/%d+%H:%M:%S",$12),strftime("%Y/%m/%d+%H:%M:%S",$13),$14,$15}' | sed 's/\s/,/g' | sed 's/+/ /g' >> $LOGNAME
	echo $count Get stream name $LINE export $LOGNAME
	count=$(expr $count + 1)
done
rm -r $LOGSTREAM



