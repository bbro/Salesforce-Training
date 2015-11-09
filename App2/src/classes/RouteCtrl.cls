public with sharing class RouteCtrl {
	public with sharing class NewRouteDetails {
		public Station__c station { get; set; }
		public Platform__c platform { get; set; }
		public DateTime arrivalTime { get; set; }
		public DateTime departureTime { get; set; }
	}
	
	public Route__c route { get; set; }
	public Id routeToShowDetailsId { get; set; }
	public List<Platform_Of_Route__c> detailsOfRoute { get; set; }
	public Id stationId {
		get {
			if (stationId==null) {
				List<Station__c> firstStation = [SELECT Id FROM Station__c LIMIT 1];
				stationId = firstStation[0].Id;
			}
			return stationId;
		} 
		set;
	}
	public Id platformId { get; set; }
	public List<Platform_Of_Route__c> platformsAddedToRoute { get; set; }
	public List<Route__c> routesToDisplay { get; set; }
	public List<NewRouteDetails> stationsAddedToRoute { get; set; }
	public List<DateTime> departureTimes { get; set; }
	public Time arrivalTime { 
        get {
            if (arrivalTime == null) {
                arrivalTime =  DateTime.now().time();
            }
            return arrivalTime;
        }
        set;
    }
	public Date departureDate { 
        get {
            if (departureDate == null) {
                departureDate =  Date.today();
            }
            return departureDate;
        }
        set;
    }
    public Time departureTime { 
        get {
            if (departureTime == null) {
                departureTime =  DateTime.now().time().addHours(1);
            }
            return departureTime;
        }
        set;
    } 
    public Date dateToFilterFrom {
    	get {
    		if (dateToFilterFrom == null) {
    			dateToFilterFrom = Date.newInstance(2015,10,5);
    		}
    		return dateToFilterFrom;
    	}
    	set;
    }
    public Date insertedDateToFilterFrom { get; set; }
    
    public RouteCtrl() {
		this.route = new Route__c();
		stationsAddedToRoute = new List<NewRouteDetails>();
		departureTimes = new List<DateTime>();
		system.debug(dateToFilterFrom);
		routesToDisplay = [SELECT Name FROM Route__c WHERE Id IN (SELECT Route__c FROM Platform_Of_Route__c  WHERE Departure_Time__c >= :dateToFilterFrom)];
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
    	NewRouteDetails detailsOfNewStation = new NewRouteDetails();
    	if (departureTime<=arrivalTime) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The arrival time cannot be later or equal to departure time!'));
    	}
    	else {
    		Station__c stationToAdd = [SELECT Name FROM Station__c WHERE Id = :stationId];
    		Platform__c platformToAdd = [SELECT Name FROM Platform__c WHERE Id = :platformId];
    		for (NewRouteDetails s : stationsAddedToRoute) {
    			if (s.station==stationToAdd) {
    				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Such station has already been added to route!'));
    				return null;
    			}
    		}
	    	DateTime dtArrivalTime = DateTime.newInstance(departureDate.year(), departureDate.month(), departureDate.day(), arrivalTime.hour(), arrivalTime.minute(), arrivalTime.second());
			DateTime dtDepartureTime = DateTime.newInstance(departureDate.year(), departureDate.month(), departureDate.day(), departureTime.hour(), departureTime.minute(), departureTime.second());
	    	for (DateTime dt : departureTimes) {
	    		if (dtArrivalTime<=dt) {
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Arrival time cannot be the same or earlier than departure time from the previous station!'));
	    			return null;
	    		}
	    	}
	    	departureTimes.add(dtDepartureTime);
	    	detailsOfNewStation.arrivalTime = dtArrivalTime;
	    	detailsOfNewStation.departureTime = dtDepartureTime;
	    	detailsOfNewStation.station = stationToAdd;
	    	detailsOfNewStation.platform = platformToAdd;
	    	stationsAddedToRoute.add(detailsOfNewStation);
    	}
    	return null;
    }
   
   public PageReference removeLastStation() {
	   if (stationsAddedToRoute.size()>0) {
		   stationsAddedToRoute.remove(stationsAddedToRoute.size()-1);
		   departureTimes.remove(departureTimes.size()-1);
		}
   		return null;
   }
   
   public PageReference clearAll() {
	   if (stationsAddedToRoute.size()>0) {
	   		this.route = new Route__c();
		   stationsAddedToRoute.clear();
		   departureTimes.clear();
		}
   		return null;
   }
   
    public PageReference addPlatformToRoute() {
		PageReference outPage;
		outPage = null;
		
		if (stationsAddedToRoute.size()<=1) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Add at least two stations to route before saving it!'));
		}
		else {
			String nameFrom = stationsAddedToRoute[0].station.Name;
			String nameTo = stationsAddedToRoute[stationsAddedToRoute.size()-1].station.Name;
			route.Name = nameFrom + ' ' + nameTo;
			insert route;
	    	for (Integer i=0;i<stationsAddedToRoute.size();i++) {
	    		Platform_Of_Route__c platformToAdd = new Platform_Of_Route__c(Arrival_Time__c = stationsAddedToRoute[i].arrivalTime,
	    															      Departure_Time__c = stationsAddedToRoute[i].departureTime,
	    															      Platform__c = stationsAddedToRoute[i].platform.Id,
	    															      Route__c = route.Id,
	    															      Station_Number__c = i+1);
		      	platformsAddedToRoute.add(platformToAdd);
	    	}
	    	try {
		    	insert platformsAddedToRoute;
			  	outPage = Page.Assign_Train_and_Carriages;
				outPage.getParameters().put('routeId', route.Id);
			  	outPage.setRedirect(true);
	    	} 
	    	catch(DMLException e){
				delete route;
				e = null;
			}
		}
	  	return outPage;
    }
    
    public PageReference showRouteDetails() {
    	system.debug(routeToShowDetailsId);
    	detailsOfRoute = [SELECT Id, Arrival_Time__c, Departure_Time__c, Platform__c, Station_Number__c, Platform__r.Station__r.Name, Route__c FROM Platform_Of_Route__c WHERE Route__r.Id = :routeToShowDetailsId];
    	PageReference routeDetailsPage = Page.RouteDetailsFromList;
    	return routeDetailsPage;
    }
    
    public PageReference filterRoutes() {
    	dateToFilterFrom = insertedDateToFilterFrom;
    	routesToDisplay = [SELECT Name FROM Route__c WHERE Id IN (SELECT Route__c FROM Platform_Of_Route__c  WHERE Departure_Time__c >= :dateToFilterFrom)];
    	return null;
    }
    
    public PageReference backToAdministratorOptions() {
		PageReference outPage = Page.OptionForAdministrator;
		return outPage;
	}
}