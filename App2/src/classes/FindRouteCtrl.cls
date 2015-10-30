public with sharing class FindRouteCtrl {
	public Id startStationId { get; set; }
	public Id endStationId { get; set; }
	private String startStationName;
	private String endStationName;
	public String routeFound { get; set; }
	public String getStartStationName() {
		Station__c station = [SELECT Name FROM Station__c WHERE Id = :startStationId];
		this.startStationName = station.Name;
		return startStationName;
	}
	public String getEndStationName() {
		Station__c station = [SELECT Name FROM Station__c WHERE Id = :endStationId];
		this.endStationName = station.Name;
		return endStationName;
	}
	public Time travelTime { 
        get {
            if (travelTime == null) {
                travelTime =  DateTime.now().time();
            }
            return travelTime;
        }
        set;
    }
    public Time arrivalTime { get; set; }
    public Time departureTime { get; set; }
    public Date departureDate {
    	get {
    		if (departureDate == null) {
    			departureDate = Date.today();
    		}
    		return departureDate;
    	}
    	set;
    }
	public String typeOfTrain { get; set; }
	public Boolean isArrivalTime { get; set; }
	public Boolean inBetweenStations { get; set; }
	public Boolean hasDisabledSupport { get; set; }
	public Boolean canTransportBicycles { get; set; }
	public Boolean packagesAvailable { get; set; }
	public Train__c train { get; set; }
	
	public FindRouteCtrl() {
		this.train = new Train__c();
	}
	public List<SelectOption> getStationsOptions() {
        List<SelectOption> stationsOptions = new List<SelectOption>();
        for(Station__c station : [SELECT Id, Name FROM Station__c]) {
	        stationsOptions.add(new SelectOption(station.Id, station.Name));
        }
        return stationsOptions;
    }
    
    public PageReference searchRoutes() {
   		List<Platform_Of_Route__c> possibleRoutes = [SELECT Route__c, Platform__c, Station_Number__c, Arrival_Time__c, Departure_Time__c 
        							     		     FROM Platform_Of_Route__c WHERE Platform__r.Station__r.Name in (:getStartStationName(), :getEndStationName())];
        List<Platform_Of_Route__c> searchResults = new List<Platform_Of_Route__c> ();
        for (Platform_Of_Route__c platformOfRoute : possibleRoutes) {
        	if (platformOfRoute.Departure_Time__c.time() >= departureTime) {
                searchResults.add(platformOfRoute);
                routeFound = platformOfRoute.Route__r.Name;
                system.debug(routeFound);
            }
        }
        return null;
    }
}