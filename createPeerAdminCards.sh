function replaceKeys() {
    rm -rf tmp/composer/org1
    rm -rf tmp/composer/org2
    rm -rf tmp/composer/connection.json

    mkdir -p tmp/composer/org1
    mkdir -p tmp/composer/org2

    CURRENT_DIR=$PWD
    cp tmp/composer/connection-template.json tmp/composer/connection.json

    export ORG1_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt)    
    perl -p -i -e 's@INSERT_ORG1_CA_CERT@$ENV{ORG1_CA_CERT}@g' tmp/composer/connection.json
    export ORG2_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt)  
    perl -p -i -e 's@INSERT_ORG2_CA_CERT@$ENV{ORG2_CA_CERT}@g' tmp/composer/connection.json
    export ORDERER_CA_CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt)
    perl -p -i -e 's@INSERT_ORDERER_CA_CERT@$ENV{ORDERER_CA_CERT}@g' tmp/composer/connection.json

    export ORG1=$CURRENT_DIR/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    cp -p $ORG1/signcerts/A*.pem tmp/composer/org1
    cp -p $ORG1/keystore/*_sk tmp/composer/org1

    export ORG2=$CURRENT_DIR/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    cp -p $ORG2/signcerts/A*.pem tmp/composer/org2
    cp -p $ORG2/keystore/*_sk tmp/composer/org2

    cp tmp/composer/connection.json tmp/composer/org1/connection-org1.json
    perl -p -i -e 's@ORG_NAME@Org1@g' tmp/composer/org1/connection-org1.json
    cp tmp/composer/connection.json tmp/composer/org2/connection-org2.json
    perl -p -i -e 's@ORG_NAME@Org2@g' tmp/composer/org2/connection-org2.json

    createCards
}

function createCards() {
    composer card create -p tmp/composer/org1/connection-org1.json -u PeerAdmin -c tmp/composer/org1/Admin@org1.example.com-cert.pem -k tmp/composer/org1/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@connection-org1.card
    composer card create -p tmp/composer/org2/connection-org2.json -u PeerAdmin -c tmp/composer/org2/Admin@org2.example.com-cert.pem -k tmp/composer/org2/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@connection-org2.card
    composer card import -f PeerAdmin@connection-org1.card --card PeerAdmin@connection-org1
    composer card import -f PeerAdmin@connection-org2.card --card PeerAdmin@connection-org2
    composer card list
}

replaceKeys
