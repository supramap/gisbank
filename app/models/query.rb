class Query < ActiveRecord::Base
  belongs_to  :project
  validates_presence_of :project_id, :name
  serialize   :virus_type, Array
  serialize   :location, Array
  serialize   :host, Array

  def isolates
    @isolates ||= find_isolates
  end

  def sequences(isos)
    sequences = [] 
    if ha == true
      sequences = sequences << 'HA'
    end
    if na == true
      sequences = sequences << 'NA'
    end
    if pb1 == true
      sequences = sequences << 'PB1'
    end
    if pb2 == true
      sequences = sequences << 'PB2'
    end
    if pa == true
      sequences = sequences << 'PA'
    end
    if np == true
      sequences = sequences << 'NP'
    end
    if m == true
      sequences = sequences << 'M'
    end
    if ns == true
      sequences = sequences << 'NS'
    end
    @seqs = []
    if sequences.empty?
      isos.each { |it| @seqs = @seqs | it.sequences} #if no boxes are checked, all the sequences of all the isolates are combined
    else
      isos.each { |it| @seqs = @seqs | it.sequences.find(:all, :conditions => { :sequence_type => sequences}) } #merges the selected sequences of all the isolates
    end
    return @seqs
  end

  private

  def find_isolates
    Isolate.find(:all, :conditions => conditions)
  end

  def isolate_name_conditions
    ["isolates.name LIKE ?", "%#{isolate_name}%"] unless isolate_name.blank?
  end

  def virus_type_conditions
    ["isolates.virus_type IN ('#{virus_type.join("','")}')"] unless virus_type == ['-ALL-']
  end

  def location_conditions
    ["isolates.location IN ('#{location.join("','")}')"] unless location == ['-ALL-']
  end

  def host_conditions
    ["isolates.host IN ('#{host.join("','")}')"] unless host == ['-ALL-']
  end

  def collect_date_conditions
    ["isolates.collect_date BETWEEN ? AND ?", min_collect_date, max_collect_date] unless min_collect_date.blank? or max_collect_date.blank?
  end

  def conditions
    [conditions_clauses.join(' AND '), *conditions_options]
  end

  def conditions_clauses
    conditions_parts.map { |condition| condition.first }
  end

  def conditions_options
    conditions_parts.map { |condition| condition[1..-1] }.flatten
  end

  def conditions_parts
    private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
  end
end
