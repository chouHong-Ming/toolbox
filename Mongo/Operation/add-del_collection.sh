#! /bin/bash


show_help() {
printf  "${Blue}Usage:${NC} sh ${0##*/} [-h] \n"
cat << EOF
       sh add-del_collection.sh -D test -U user -A password -c -a 1 -d -b 2 -p ming -P test -i '{ "receivedData": "hashed" }'

    --help  display this help and exit
    -h  display this help and exit
    -H  set the Mongo DB IP
        Default is 127.0.0.1
    -O  set the Mongo DB port
        Default is 27017
    -D  set the database that you want to operate in Mongo DB
    -U  set the Mongo DB user
    -A  set the Mongo DB password
    -p  add the prefix to the collection name,the collection name will be [prefix]_[date(yyyy_mm_dd)]
    -P  add the postfix to the collection name,the collection name will be [date(yyyy_mm_dd)]_[postfix]
    -c  create the collection if the collection isn't exist
    -d  delete the collection if the collection is exist
    -i  add the option to the command of adding index when creating collection, please use single quote to include the index json content, ex: '{ "receivedData": "hashed" }'
    -b  if -d is set, need to set the number of days that the script will delete the collection before today
        Default is 3
    -a  id -c is set, need to set the number of days that the script will create the collection after today
        Default is 3
EOF
}

collection_exist() {
if [ "$(echo $COLLECTION_LIST | grep $1)" ]; then
    true
else
    false
fi
}


for I in "$@"
do
    case $I in
        --help)
            show_help
            exit ;;
    esac
done

DATABASE_HOST=127.0.0.1
DATABASE_PORT=27017
CREATE=false
DROP=false
AFTER=3
BEFORE=3
while getopts hH:O:D:U:A:p:P:cdi:b:a: argv;
do
    case $argv in
        h)
            show_help
            exit
            ;;
        H)
            DATABASE_HOST=$OPTARG
            ;;
        O)
            DATABASE_PORT=$OPTARG
            ;;
        D)
            DATABASE_NAME=$OPTARG
            ;;
        U)
            DATABASE_USER=$OPTARG
            ;;
        A)
            DATABASE_PASSWORD=$OPTARG
            ;;
        p)
            PREFIX=$OPTARG"_"
            ;;
        P)
            POSTFIX="_"$OPTARG
            ;;
        c)
            CREATE=true
            ;;
        d)
            DROP=true
            ;;
        i)
            INDEX=$OPTARG
            echo $INDEX
            ;;
        b)
            BEFORE=$OPTARG
            if [ $BEFORE -gt 0 -a $BEFORE%1!=0 ]; then
                echo "Will delete the collection for last $BEFORE days"
            else
                echo "-b parameter CAN NOT less than or equal 0 or is invalid"
                exit
            fi
            ;;
        a)
            AFTER=$OPTARG
            if [ $AFTER -ge 0 -a $AFTER%1!=0 ]; then
                echo "Will create the collection for next $AFTER days"
            else
                echo "-a parameter CAN NOT less than 0 or is invalid"
                exit
            fi
            ;;
    esac
done

test -z $DATABASE_NAME && echo "[ERROR] Please provide the database name that you want to operate with option -D. Exiting..." && exit 1
test -z $DATABASE_USER && echo "[ERROR] Please provide the database user with option -U. Exiting..." && exit 1
test -z $DATABASE_PASSWORD && echo "[ERROR] Please provide the database password with option -A. Exiting..." && exit 1


TODAY=$(date +"%Y_%m_%d")
echo $TODAY

COLLECTION_LIST=$(mongo $DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME -u $DATABASE_USER -p $DATABASE_PASSWORD --eval "db.getCollectionNames()" | cut -d" " -f 8-)


if $CREATE; then
    echo "Do Create"
    if ! collection_exist $PREFIX$TODAY$POSTFIX; then
        echo "Create Collection $PREFIX$TODAY$POSTFIX"
        mongo $DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME -u $DATABASE_USER -p $DATABASE_PASSWORD --eval "db.createCollection(\"$PREFIX$TODAY$POSTFIX\")"
        if [ "$INDEX" ]; then
            mongo $DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME -u $DATABASE_USER -p $DATABASE_PASSWORD --eval "db.getCollection('$PREFIX$TODAY$POSTFIX').createIndex($INDEX)"
        fi
    fi

    FLAG=1
    while [ $(($AFTER+1)) -ne $FLAG ];
    do
        TARGET=$PREFIX$(date --date="+$FLAG day" +"%Y_%m_%d")$POSTFIX
        if ! collection_exist $TARGET; then
            echo "Create Collection $TARGET"
            mongo $DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME -u $DATABASE_USER -p $DATABASE_PASSWORD --eval "db.createCollection(\"$TARGET\")"
            if [ "$INDEX" ]; then
                mongo $DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME -u $DATABASE_USER -p $DATABASE_PASSWORD --eval "db.getCollection('$TARGET').createIndex($INDEX)"
            fi
        fi
        FLAG=$(($FLAG+1))
    done
fi

if $DROP && [ "${BEFORE}" -gt 0 ]; then
    echo "Do Drop"
    FLAG=1
    while [ $(($BEFORE+1)) -ne $FLAG ];
    do
        TARGET=$PREFIX$(date --date="-$FLAG day" +"%Y_%m_%d")$POSTFIX
        if collection_exist $TARGET; then
            echo "Drop Collection $TARGET"
            mongo $DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME -u $DATABASE_USER -p $DATABASE_PASSWORD --eval "db.$TARGET.remove({})"
            mongo $DATABASE_HOST:$DATABASE_PORT/$DATABASE_NAME -u $DATABASE_USER -p $DATABASE_PASSWORD --eval "db.$TARGET.drop()"
        fi
        FLAG=$(($FLAG+1))
    done
fi

if ! ${CREATE} && ! ${DROP}; then
    echo "Curren Collection List:"
    echo $COLLECTION_LIST
fi

