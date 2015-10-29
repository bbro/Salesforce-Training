public with sharing class RouteCtrl {
	public Route__c route { get; set; }
	public Id stationId { get; set; }
	public Id platformId { get; set; }
	public List<Platform_Of_Route__c> platformsAddedToRoute { get; set; }
	public List<Station__c> stationsAddedToRoute { get; set; }
	public List<DateTime> arrivalTimes { get; set; }
	public List<DateTime> departureTimes { get; set; }
	public List<Platform__c> platformsOfRoute { get; set; }
	public Time arrivalTime { 
        get {
            if (arrivalTime == null) {
                arrivalTime =  DateTime.now().time();
            }
            return arrivalTime;
        }
        set;
    }
    
    public Time departureTime { get; set; } 

	public RouteCtrl() {
		this.route = new Route__c();
		platformsAddedToRoute = new List<Platform_Of_Route__c>();
		stationsAddedToRoute = new List<Station__c>();
		platformsOfRoute = new List<Platform__c>();
		arrivalTimes = new List<DateTime>();
		departureTimes = new List<DateTime>();
	}
	
	public List<SelectOption> getStationsOptions() {
        List<SelectOption> stationsOptions = new List<SelectOption>();
        for(Station__c station : [SELECT Id, Name FROM Station__c]) {
	        stationsOptions.add(new SelectOption(station.Id, station.Name));
        }
        return stationsOptions;
    }
    
    public List<SelectOption> getPlatformsOptions() {
    	List<SelectOption> platformsOptions = new List<SelectOption>();
        for(Platform__c platform : [SELECT Id, Name FROM Platform__c WHERE Station__r.Id = :stationId]) {
	        platformsOptions.add(new SelectOption(platform.Id, platform.Name));
        }
        return platformsOptions;
    }
    
    public PageReference addDataToLists() {
    	Date dt = date.today();
    	DateTime dtArrivalTime = DateTime.newInstance(dt.year(), dt.month(), dt.day(), arrivalTime.hour(), arrivalTime.minute(), arrivalTime.second());
		DateTime dtDepartureTime = DateTime.newInstance(dt.year(), dt.month(), dt.day(), departureTime.hour(), departureTime.minute(), departureTime.second());
    	Station__c stationToAdd = [SELECT Name FROM Station__c WHERE Id = :stationId];
    	Platform__c platformToAdd = [SELECT Name FROM Platform__c WHERE Id = :platformId];
    	stationsAddedToRoute.add(stationToAdd);
    	platformsOfRoute.add(platformToAdd);
    	arrivalTimes.add(dtArrivalTime);
    	departureTimes.add(dtDepartureTime);
    	return null;
    }
   
    public PageReference addPlatformToRoute() {
		String nameFrom = stationsAddedToRoute[0].Name;
		String nameTo = stationsAddedToRoute[stationsAddedToRoute.size()-1].Name;
		route.Name = nameFrom + ' ' + nameTo;
		insert route;
    	for (Integer i=0;i<stationsAddedToRoute.size();i++) {
    		Platform_Of_Route__c platformToAdd = new Platform_Of_Route__c(Arrival_Time__c = arrivalTimes[i],
    															      Departure_Time__c = departureTimes[i],
    															      Platform__c = platformsOfRoute[i].Id,
    															      Route__c = route.Id,
    															      Station_Number__c = i+1);
	      	platformsAddedToRoute.add(platformToAdd);
    	}
    	insert platformsAddedToRoute;
			PageReference ref = Page.Assign_Train_and_Carriages;
			ref.getParameters().put('routeId', route.Id);
			ref.setRedirect(true);
			return ref;
    }
}