class MassInteractionsController < ApplicationController
  respond_to :html, :json

#  def index
#    @mass_interactions = MassInteraction.all
#    respond_with(@mass_interactions)
#  end

#  def show
#    @mass_interaction = MassInteraction.find(params[:id])
#    respond_with(@mass_interaction)
#  end

  def new
    @interaction = Interaction.find_subclass("Contact").new
    @mass_interaction = MassInteraction.new
    @mass_interaction.original = @interaction
    @mass_interaction.people = current_scope.people.find(params[:people] || [])

    respond_with(@mass_interaction)
  end

#  def edit
#    @mass_interaction = MassInteraction.find(params[:id])
#  end

  def create
    @interaction = Interaction.find_subclass("Contact").new(params[:mass_interaction])
    @mass_interaction = MassInteraction.new(params[:mass_interaction])
    @mass_interaction.user = current_user
    @mass_interaction.original = @interaction
    if @mass_interaction.save
      flash[:notice] = 'Mass interaction was successfully created.'
      respond_with(@mass_interaction) do |format|
        format.html { redirect_to people_path }
      end
    else
      respond_with(@mass_interaction)
    end
  end

#  def update
#    @mass_interaction = MassInteraction.find(params[:id])
#    flash[:notice] = 'MassInteraction was successfully updated.' if @mass_interaction.update_attributes(params[:mass_interaction])
#    respond_with(@mass_interaction)
#  end

#  def destroy
#    @mass_interaction = MassInteraction.find(params[:id])
#    @mass_interaction.destroy
#    respond_with(@mass_interaction)
#  end
end
