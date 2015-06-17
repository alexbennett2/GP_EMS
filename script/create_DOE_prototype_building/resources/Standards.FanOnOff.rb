
# open the class to add methods to return sizing values
class OpenStudio::Model::FanOnOff

  # Sets the fan motor efficiency based on the standard
  def setStandardEfficiency(template, hvac_standards)
    
    motors = hvac_standards["motors"]
    
    # Get the max flow rate from the fan.
    maximum_flow_rate_m3_per_s = nil
    if self.maximumFlowRate.is_initialized
      maximum_flow_rate_m3_per_s = self.maximumFlowRate.get
    elsif self.autosizedMaximumFlowRate.is_initialized
      maximum_flow_rate_m3_per_s = self.autosizedMaximumFlowRate.get
    else
      OpenStudio::logFree(OpenStudio::Warn, "openstudio.hvac_standards.FanOnOff", "For #{self.name} max flow rate is not available, cannot apply efficiency standard.")
      return false
    end
    
    # Convert max flow rate to cfm
    maximum_flow_rate_cfm = OpenStudio.convert(maximum_flow_rate_m3_per_s, "m^3/s", "cfm").get
    
    # Get the pressure rise from the fan
    pressure_rise_pa = self.pressureRise
    pressure_rise_in_h2o = OpenStudio.convert(pressure_rise_pa, "Pa","inH_{2}O").get
    
    # Assume that the fan efficiency is 65% based on
    #TODO need reference
    fan_eff = 0.65
    
    # Calculate the Brake Horsepower
    brake_hp = (pressure_rise_in_h2o * maximum_flow_rate_cfm)/(fan_eff * 6356) 
    allowed_hp = brake_hp * 1.1 # Per PNNL document #TODO add reference

    # Find the motor that meets these size criteria
    search_criteria = {
    "template" => template,
    "number_of_poles" => 4.0,
    "type" => "Open Drip-Proof",
    }
    
    motor_properties = find_object(motors, search_criteria, allowed_hp)
  
    # Get the nominal motor efficiency
    motor_eff = motor_properties["nominal_full_load_efficiency"]
  
    # Calculate the total fan efficiency
    total_fan_eff = fan_eff * motor_eff
    
    # Set the total fan efficiency and the motor efficiency
    self.setFanEfficiency(total_fan_eff)
    self.setMotorEfficiency(motor_eff)
    
    # Set the fan efficiency ration function of speed ratio curve to a
    # flat number per the IDFs.  Not sure how this invalid input affects
    # the simulation, but it is in the Prototype IDF files.
    # TODO check if this is just for small office or every building type
    #fan_eff_curve = self.fanEfficiencyRatioFunctionofSpeedRatioCurve
    #fan_eff_curve = fan_eff_curve.to_CurveCubic.get
    #fan_eff_curve.setCoefficient1Constant(total_fan_eff)
    
    OpenStudio::logFree(OpenStudio::Info, "openstudio.hvac_standards.FanOnOff", "For #{template}: #{self.name}: allowed_hp = #{allowed_hp.round(1)}HP; motor eff = #{(motor_eff*100).round(2)}%; total fan eff = #{(total_fan_eff*100).round}%")
    
    return true
    
  end

  # Determines the fan power (W)
  def fanPower()
    
    # Get design supply air flow rate (whether autosized or hard-sized)
    dsn_air_flow_m3_per_s = 0
    if self.autosizedDesignSupplyAirFlowRate.is_initialized
      dsn_air_flow_m3_per_s = self.autosizedDesignSupplyAirFlowRate.get
    else
      dsn_air_flow_m3_per_s = self.designSupplyAirFlowRate.get
    end
  
    # Get the total fan efficiency
    fan_total_eff = fan.fanEfficiency
    
    # Get the pressure rise (Pa)
    pressure_rise_pa = fan.pressureRise
    
    # Calculate the fan power (W)
    fan_power_w = pressure_rise_pa * dsn_air_flow_m3_per_s / fan_total_eff
    
    return fan_power_w
  
  end

  # Determines the brake horsepower of the fan
  def brakeHorsepower()
  
    # Get the fan motor efficiency
    fan_motor_eff = fan.motorEfficiency
  
    # Get the fan power (W)
    fan_power_w = self.fanPower
    
    # Calculate the brake horsepower (bhp)
    fan_bhp = fan_power_w * fan_motor_eff / 746
    
    return fan_bhp

  end

  # Changes the fan motor efficiency and also the fan total efficiency
  # at the same time, preserving the impeller efficiency.
  def changeMotorEfficiency(motor_eff)
    
    # Calculate the existing impeller efficiency
    existing_motor_eff = self.motorEfficiency
    existing_total_eff = self.fanEfficiency
    existing_impeller_eff = existing_total_eff / existing_motor_eff
    
    # Calculate the new total efficiency
    new_total_eff = motor_eff * existing_impeller_eff
    
    # Set the revised motor and total fan efficiencies
    self.setMotorEfficiency(motor_eff)
    self.setFanEfficiency(new_total_eff)
  
  end

  # Changes the fan impeller efficiency and also the fan total efficiency
  # at the same time, preserving the motor efficiency.
  def changeImpellerEfficiency(impeller_eff)
    
    # Get the existing motor efficiency
    existing_motor_eff = self.motorEfficiency

    # Calculate the new total efficiency
    new_total_eff = existing_motor_eff * impeller_eff
    
    # Set the revised motor and total fan efficiencies
    self.setFanEfficiency(new_total_eff)
  
  end
  
  # Determines the baseline fan impeller efficiency
  # based on the specified fan type.
  def baselineImpellerEfficiency(template)
  
    # Assume that the fan efficiency is 65% based on
    # TODO need reference
    # TODO add fan type to fan data model
    # and infer impeller efficiency from that?
    # or do we always assume a certain type of
    # fan impeller for the baseline system?
    # TODO check COMNET and T24 ACM and PNNL 90.1 doc
    fan_impeller_eff = 0.65
  
    return fan_impeller_eff
  
  end
  
  # Determines the minimum fan motor efficiency 
  # for a given motor bhp
  def standardMinimumMotorEfficiency(template, hvac_standards, motor_bhp)
  
    # Lookup the minimum motor efficiency
    motors = hvac_standards["motors"]
    
    # Assuming all fan motors are 4-pole ODP
    search_criteria = {
      "template" => template,
      "number_of_poles" => 4.0,
      "type" => "Open Drip-Proof",
    }
    
    motor_properties = find_object(motors, search_criteria, motor_bhp)
 
    fan_motor_eff = motor_properties["nominal_full_load_efficiency"]  

    return fan_motor_eff
  
  end
  
end
