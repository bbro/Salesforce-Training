public class CityStationPlatformCtrl {
	public String cityName {get;set;}
	public String stationName {get;set;}
	public String platformAmount {get;set;}
	public Boolean isMainStation {get; set;}
	public Station__c station {get;set;}
	public Id cityId {get;set;}
	
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
		Boolean stationNameProperCharacters = !stationName.isWhitespace() && stationName.isAlphaSpace();
		Boolean platformsProperCharacters = platformAmount.isNumeric() && Integer.valueOf(platformAmount) < 10 && Integer.valueOf(platformAmount) > 0;
		PageReference outPage = null;
		List<Station__c> stationWithName = [SELECT Name from Station__c where Name = :stationName];
		
		if(stationWithName.size() == 0) {
			if (stationNameProperCharacters && platformsProperCharacters) {
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
				
				platformAmount = '';
				stationName = '';
				isMainStation = false;
				station.City__c = null;
				outPage = Page.Stations;
			}
			else if (!stationNameProperCharacters) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Wrong station name format'));
				outPage = null;
			}
			else if (!platformsProperCharacters) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Wrong number of platforms format'));
				outPage = null;
			}
		}
		else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Station with that name exist'));
			outPage = null;
		}
		return outPage;
	}
	
	public PageReference saveNewCity() {
		PageReference outPage = Page.Cities;
		Boolean nameProperCharacters = !cityName.isWhitespace() && cityName.isAlphaSpace();
		
		if (nameProperCharacters) {
			if (cityId == null) {
				List<City__c> citiesWithName = [SELECT Name FROM City__c WHERE Name = :cityName];
				if (citiesWithName.size() == 0) {
					City__c tempCity = new City__c();
					tempCity.Name = cityName;
					insert tempCity;
					cityName = '';
				}
				else {
					outPage = null;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'City with that name already exists'));
				}
			}
			else {
				City__c tempCity = [SELECT Name from City__c WHERE Id = :cityId];
				tempCity.Name = cityName;
				update tempCity;
				cityId = null;
			}
		}
		else {
			outPage = null;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Name should contains only letters and spaces'));
		}
	return outPage;
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
	public PageReference backToAdministratorOptions() {
		PageReference outPage = Page.OptionForAdministrator;
		return outPage;
	}
	
	public PageReference updateCity () {
		City__c selectedCity = [SELECT Name from City__c WHERE Id = :cityId];
		cityName = selectedCity.Name;
		return Page.Add_City;
	}
}