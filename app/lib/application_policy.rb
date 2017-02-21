class ApplicationPolicy
  
  attr_accessor :user, :record

  def initialize(user, record)
    self.user = user || User.new
    self.record = record
  end

  def index?
    admin?
  end

  def show?
    admin?
  end

  def show_in_app?
    show?
  end
  
  def kuina_show_in_app?
    show_in_app?
  end
  
  def new_or_create?
    admin?
  end
  
  def create?
    new_or_create?
  end

  def new?
    new_or_create?
  end
  
  def edit_or_update?
    admin?
  end
  
  def update?
    edit_or_update?
  end

  def edit?
    edit_or_update?
  end

  def destroy?
    admin?
  end
  
  def dashboard?
    admin? || keeper?
  end
  
  def history?
    admin?
  end
  
  def export?
    admin?
  end
  
  def review?
    admin? && record.subject_to_review? && !reviewed?
  end
  
  def perform_review?
    review? && !reviewed?
  end
  
  def charge?
    chargeable?
  end
  
  def true?
    true
  end
  
  def chargeable?
    (owned_by_this_user? || (development? ? admin? : false)) && record.approved? && record.payable?
  end
  
  def expirable?
    (keeper? || (development? ? admin? : false)) && record.approved? && record.active
  end 

  def owned_by_this_user?
    record.user == user
  end
  
  def reviewed?
    record.try(:approved_at?) || record.try(:rejected_at?)
  end
  
  def admin?
    user.try :admin?
  end
  
  def keeper?
    user.try :keeper?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end
  
  def records
    record
  end
  
  class Scope
    attr_accessor :user, :scope

    def initialize(user, scope)
      self.user = user
      self.scope = scope
    end

    def resolve
      scope
    end
  end
  
  def self.policy_class
    self
  end
  
  protected
  
  def logged_in?
    user.id.present?
  end
  
end
