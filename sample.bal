import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/graphql;
import ballerina/sql;
import ballerina/log;
import ballerina/os;

# A service representing a network-accessible GraphQL API
@display {
    label: "nadac",
    id: "nadac-9556d2ce-92b5-45b8-b8a2-85e7136458b8"
}
service / on new graphql:Listener(8090) {

    @display {
        label: "mysql",
        id: "mysql-b274841b-8215-48ba-b457-301050d89670"
    }
    mysql:Client mysqlEp;

    function init() returns error? {
        self.mysqlEp = check new (host = dbHost, user = dbUser, password = dbPassword, database = dbName, port = 3306);
    }

    resource function get findByNDC(string ndc) returns NADACInfo[]|error {
        if ndc is "" {
            return error("ndc should not be empty!");
        }
        log:printInfo("find by ndc:", ndc = ndc);
        stream<NADACInfo, sql:Error?> infoStream = self.mysqlEp->query(sqlQuery = `SELECT * FROM nadac WHERE ndc = ${ndc}`);
        return from NADACInfo info in infoStream
            select info;
    }

    resource function get findByDescription(string description) returns NADACInfo[]|error {
        if description is "" {
            return error("description should not be empty!");
        }

        string searchTerm = string `%${description}%`;

        log:printInfo("searching for drug description:", searchTerm = searchTerm);
        stream<NADACInfo, sql:Error?> infoStream = self.mysqlEp->query(sqlQuery = `SELECT * FROM nadac WHERE ndc_description like ${searchTerm}`);
        return from NADACInfo info in infoStream
            select info;
    }

}

type NADACInfo record {
    @sql:Column {name: "ndc_description"}
    string description;

    @sql:Column {name: "ndc"}
    string ndc;

    @sql:Column {name: "nadac_per_unit"}
    float nadac_PerUnit;

    @sql:Column {name: "effective_date"}
    string effectiveDate;

    @sql:Column {name: "pricing_unit"}
    string pricingUnit;

    @sql:Column {name: "pharmacy_type_indicator"}
    string pharmacyTypeIndicator;

    @sql:Column {name: "otc"}
    string oTC;

    @sql:Column {name: "explanation_code"}
    string explanationCode;

    @sql:Column {name: "classification_for_rate_setting"}
    string classificationForRateSetting;

    @sql:Column {name: "corresponding_generic_drug_nadac_per_unit"}
    string correspondingGenericDrugNADACPerUnit;

    @sql:Column {name: "corresponding_generic_drug_effective_date"}
    string CorrespondingGenericDrugEffectiveDate;

    @sql:Column {name: "as_of_date"}
    string asOfDate;
};

configurable string dbHost = os:getEnv("DB_HOST");
configurable string dbUser = os:getEnv("DB_USERNAME");
configurable string dbPassword = os:getEnv("DB_PASSWORD");
configurable string dbName = os:getEnv("DB_NAME");
