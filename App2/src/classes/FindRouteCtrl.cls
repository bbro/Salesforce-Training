public with sharing class FindRouteCtrl {
	public Id startStationId { get; set; }
	public Id endStationId { get; set; }
	public Id trainFoundId { get; set; }
	public Id routeToBuyTicketForId;
	private String startStationName;
	private String endStationName;
	public List<String> foundRoutesNames { get; set; }
	public List<Train_on_Route__c> foundTrainsOnRoute { get; set; }
	public List<Train_on_Route__c> foundTrainsOnRouteResults { get; set; }
	public Set<Train_on_Route__c> foundTrainsOnRouteSet { get; set; }
	public List<Platform_Of_Route__c> detailsOfRoute { get; set; }
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

    	foundRoutesNames = new List<String>();
    	foundTrainsOnRoute = new List<Train_on_Route__c>();
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
                if (startPlatformOfRoute.Station_Number__c < endPlatformOfRoute.Station_Number__c) {
                    if (!isArrivalTime && startPlatformOfRoute.Departure_Time__c >= travelDateTime) {
                    	searchedRoutesId.add(startPlatformOfRoute.Route__c);
                    }
                    else if (isArrivalTime && endPlatformOfRoute.Arrival_Time__c <= travelDateTime) {
                            searchedRoutesId.add(endPlatformOfRoute.Route__c);
                    }
                }
        }
        
        // search trains by route id
        String trainsQuery = 'SELECT Train__c, Route__c, Route__r.Name, Train__r.Name FROM Train_on_Route__c WHERE Route__c in :searchedRoutesId AND Train__r.Type__c = :typeOfTrain';
        List<Train_on_Route__c> trainsOnSearchedRoutes = new List<Train_on_Route__c>();
        if (packagesAvailable) {
        	trainsOnSearchedRoutes = Database.query(trainsQuery + ' AND Train__r.Allow_Packages__c = true');
        }
        else {
        	trainsOnSearchedRoutes = Database.query(trainsQuery);
        }
        //List<Carriage_on_Train__c> carriagesOnTrainsOnSearchedRoutes = new List<Carriage_on_Train__c> ();
        Map<Id, Train_on_Route__c> trainIdToTrainRoutes = new Map<Id, Train_on_Route__c>();
        for (Train_on_Route__c train : trainsOnSearchedRoutes) {
        	trainIdToTrainRoutes.put(train.Train__c, train);
        }
        String carriagesQuery = 'SELECT Train__c FROM Carriage_on_Train__c WHERE Train__c in :trainIds';
        List<String> whereStmts = new List<String>();
        List<Id> trainIds = new List<Id>(trainIdToTrainRoutes.keySet());
    	/*if (trainIds.size() > 0) {
    		whereStmts.add('Train__c in :trainIds');
    		//carriagesQuery += ' WHERE Train__c in :trainIds';
    	}*/
    	if (canTransportBicycles) {
    		//whereStmts.add('Carriage__r.Bicycles_Transport__c = true');
    		carriagesQuery += ' AND Carriage__r.Bicycles_Transport__c = true';
    	}
    	if (hasDisabledSupport) {
    		//whereStmts.add('Carriage__r.Disabled_People_Support__c = true');
    		carriagesQuery += ' AND Carriage__r.Disabled_People_Support__c = true';
    	}
    	
    	/*if (whereStmts.size() > 0) {
    		carriagesQuery += String.join(whereStmts, ' AND ');
    	}*/
    	//system.debug(carriagesQuery);
    	for (Carriage_on_Train__c carriageOfTrain : Database.query(carriagesQuery)) {
    		foundTrainsOnRoute.add(trainIdToTrainRoutes.get(carriageOfTrain.Train__c));
    	}
    	foundTrainsOnRouteSet = new Set<Train_On_Route__c>();
    	foundTrainsOnRouteSet.addAll(foundTrainsOnRoute);
    	foundTrainsOnRouteResults = new List<Train_On_Route__c>();
    	foundTrainsOnRouteResults.addAll(foundTrainsOnRouteSet);
    	/*for (Train_On_Route__c t : foundTrainsOnRoute) {
    		if (foundTrainsOnRouteSet.add(t)) {
    			foundTrainsOnRouteResults.add(t);
    		}
    	}*/
        return null;
    }
    
    public PageReference goToTicketPage() {
    	PageReference ticketPage = Page.TicketCtrlPage;
    	ticketPage.getParameters().put('routeToBuyTicketForId', [SELECT Route__c FROM Train_On_Route__c WHERE Id = :trainFoundId].Route__c);
    	ticketPage.getParameters().put('stationFromName', getStartStationName());
    	ticketPage.getParameters().put('stationToName', getEndStationName());
    	ticketPage.getParameters().put('trainFoundId',trainFoundId);
	  	ticketPage.setRedirect(true);
    	return ticketPage;
    }
    
    public PageReference goToPackagePage() {
		PageReference packagePage = null;
		if ([SELECT Id, Allow_Packages__c FROM Train__c WHERE Id IN (SELECT Train__c FROM Train_On_Route__c WHERE Id = :trainFoundId)].Allow_Packages__c) {
	    	packagePage = Page.Packages;
	    	packagePage.getParameters().put('routeToSendPackageOnId', [SELECT Route__c FROM Train_On_Route__c WHERE Id = :trainFoundId].Route__c);
	    	packagePage.getParameters().put('stationFromName', getStartStationName());
	    	packagePage.getParameters().put('stationToName', getEndStationName());
	    	packagePage.getParameters().put('trainFoundId',trainFoundId);
		  	packagePage.setRedirect(true);
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This train does not allow sending packages'));
		}
		return packagePage;
    }
    
    public PageReference goToRouteDetails() {
    	this.routeToBuyTicketForId = [SELECT Route__c FROM Train_On_Route__c WHERE Id = :trainFoundId].Route__c;
    	detailsOfRoute = [SELECT Arrival_Time__c, Departure_Time__c, Platform__c, Station_Number__c, Platform__r.Station__r.Name, Route__c FROM Platform_Of_Route__c WHERE Route__r.Id = :routeToBuyTicketForId];
    	PageReference routeDetailsPage = Page.RouteDetails;
    	return routeDetailsPage;
    }
}