public with sharing class FindRouteCtrl {
	public Id startStationId { get; set; }
	public Id endStationId { get; set; }
	private String startStationName;
	private String endStationName;
	public List<String> foundRoutesNames { get; set; }
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
		foundRoutesNames = new List<String>();
	}
	public List<SelectOption> getStationsOptions() {
        List<SelectOption> stationsOptions = new List<SelectOption>();
        for(Station__c station : [SELECT Id, Name FROM Station__c]) {
	        stationsOptions.add(new SelectOption(station.Id, station.Name));
        }
        return stationsOptions;
    }
    
    public PageReference searchRoutes() {

    	foundRoutesNames = new List<String>();
    	Platform_Of_Route__c startPlatformOfRoute = new Platform_Of_Route__c();
    	Platform_Of_Route__c endPlatformOfRoute = new Platform_Of_Route__c();
    	
   		List<Platform_Of_Route__c> possibleRoutes = [SELECT Route__c, Platform__r.Station__r.Name, Route__r.Name, Platform__c, Station_Number__c, Arrival_Time__c, Departure_Time__c 
        							     		     FROM Platform_Of_Route__c WHERE Platform__r.Station__r.Name in (:getStartStationName(), :getEndStationName())];
        List<Id> searchedRoutesId = new List<Id>();
        
        DateTime travelDateTime = DateTime.newinstance(departureDate.year(), departureDate.month(), departureDate.day(), travelTime.hour(), travelTime.minute(), travelTime.second());
        for (Platform_Of_Route__c platformOfRoute : possibleRoutes) {
    		if (platformOfRoute.Platform__r.Station__r.Name == getStartStationName())
    			startPlatformOfRoute = platformOfRoute;
    		if (platformOfRoute.Platform__r.Station__r.Name == getEndStationName())
    			endPlatformOfRoute = platformOfRoute;
    		if (startPlatformOfRoute.Station_Number__c<endPlatformOfRoute.Station_Number__c) {
    			if (isArrivalTime) {
	    			if (platformOfRoute.Arrival_Time__c <= travelDateTime) {
		                searchedRoutesId.add(platformOfRoute.Route__c);
	        		}
    			} else {
	    			if (platformOfRoute.Departure_Time__c >= travelDateTime) {
		                searchedRoutesId.add(platformOfRoute.Route__c);
	        		}
    			}
    		}
        }
        
        // search trains by route id
        List<Train_on_Route__c> trainsOnSearchedRoutes = new List<Train_on_Route__c>();
        trainsOnSearchedRoutes = [SELECT Train__c, Route__c, Route__r.Name, Train__r.Name from Train_on_Route__c where Route__c in :searchedRoutesId and Train__r.Type__c = :typeOfTrain and Train__r.Allow_Packages__c = :packagesAvailable];
        List<Carriage_on_Train__c> carriagesOnTrainsOnSearchedRoutes = new List<Carriage_on_Train__c> ();
        
        for (Train_on_Route__c train : trainsOnSearchedRoutes) {
        	Boolean trainHasProperCarriage = false;
        	for (Carriage_on_Train__c cr : [SELECT Carriage__c, Carriage__r.Disabled_People_Support__c, Carriage__r.Bicycles_Transport__c, Name, Id, Train__c from Carriage_on_Train__c where Train__c = :train.Train__c ]) {
        		
        		if (cr.Carriage__r.Bicycles_Transport__c == canTransportBicycles && 
        			cr.Carriage__r.Disabled_People_Support__c == hasDisabledSupport) {
        				trainHasProperCarriage = true;
        				break;
        		}
        	}
        	if (trainHasProperCarriage) {
        		foundRoutesNames.add(train.Route__r.Name + ' ' + train.Train__r.Name);
        	}
        }
        return null;
    }
}