public class CityStationPlatformCtrl {
	public String cityName {get;set;}
	public String stationName {get;set;}
	public String platformAmount {get;set;}
	public Boolean isMainStation {get; set;}
	public Station__c station {get;set;}
	
	public CityStationPlatformCtrl() {
		this.station = new Station__c();
	}
	
	public List<City__c> getAllCities() {
		List<City__c> allCities = [SELECT Name FROM City__c];
		return allCities;
	}
	
	public List<Station__c> getAllStations() {
		List<Station__c> allStations = [SELECT Name, City__c, Is_Main_Station__c FROM Station__c];
		return allStations;
	}
	
	public PageReference saveNewStation() {
		Station__c currentStation = new Station__c();
		currentStation.Is_Main_Station__c = isMainStation;
		currentStation.Name = stationName;
		currentStation.City__c = station.City__c;
		
		insert currentStation;
		
		List<Platform__c> platforms = new List<Platform__c>();
		for(Integer i = 1; i <= Integer.valueOf(platformAmount); i++ ) {
			Platform__c p = new Platform__c();
			p.Platform_Number__c = i;
			p.Station__c = currentStation.id;
			platforms.add(p);
		} 
		insert platforms;
		return Page.Stations;
	}
	
	// page references
	public PageReference saveNewCity() {
		City__c tempCity = new City__c();
		tempCity.Name = CityName;
		insert tempCity;
		return Page.Cities;
	}
	
	public PageReference gotoEditStation() {
		List<Station__c> tempStations = [SELECT Id, Name, City__c, Is_Main_Station__c FROM Station__c WHERE Id = :station.Id];
		station = tempStations[0];
		return Page.EditStation;
	}

	public PageReference updateStation() {
		update station;
		return Page.Stations;
	}
	
	public PageReference gotoStations() {
		return Page.Stations;
	}
	
	public PageReference deleteStation() {
		delete station;
		station = new Station__c();
		return Page.Stations;
	}
}