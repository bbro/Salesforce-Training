public with sharing class RouteCtrl {
	public Route__c route { get; set; }
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
	public List<Route__c> allRoutes { get; set; }
	public List<Station__c> stationsAddedToRoute { get; set; }
	public List<Station__c> comparingList { get; set; }
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

	public RouteCtrl() {
		this.route = new Route__c();
		platformsAddedToRoute = new List<Platform_Of_Route__c>();
		stationsAddedToRoute = new List<Station__c>();
		platformsOfRoute = new List<Platform__c>();
		arrivalTimes = new List<DateTime>();
		departureTimes = new List<DateTime>();
		allRoutes = [SELECT Name FROM Route__c];
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
    	if (departureTime<=arrivalTime) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The arrival time cannot be later or equal to departure time!'));
    	}
    	else {
    		Station__c stationToAdd = [SELECT Name FROM Station__c WHERE Id = :stationId];
    		Platform__c platformToAdd = [SELECT Name FROM Platform__c WHERE Id = :platformId];
    		for (Station__c s : stationsAddedToRoute) {
    			if (s.Name==stationToAdd.Name) {
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
	    	arrivalTimes.add(dtArrivalTime);
	    	departureTimes.add(dtDepartureTime);
	    	stationsAddedToRoute.add(stationToAdd);
	    	platformsOfRoute.add(platformToAdd);
    	}
    	return null;
    }
   
   public PageReference removeLastStation() {
	   if (stationsAddedToRoute.size()>0) {
		   stationsAddedToRoute.remove(stationsAddedToRoute.size()-1);
		   arrivalTimes.remove(arrivalTimes.size()-1);
		   departureTimes.remove(departureTimes.size()-1);
		   platformsOfRoute.remove(platformsOfRoute.size()-1);
		}
   		return null;
   }
   
   public PageReference clearAll() {
	   if (stationsAddedToRoute.size()>0) {
		   stationsAddedToRoute.clear();
		   arrivalTimes.clear();
		   departureTimes.clear();
		   platformsOfRoute.clear();
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
		  	outPage = Page.Assign_Train_and_Carriages;
			outPage.getParameters().put('routeId', route.Id);
		  	outPage.setRedirect(true);
		}
	  	return outPage;
    }
}