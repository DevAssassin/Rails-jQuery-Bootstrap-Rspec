class InteractionsController < ApplicationController
  respond_to :html, :json

  # TODO: I don't think this method is necessary at all b/c it's handled by
  # dashboard_controller.  We can probably just use this for the json api.
  def index
    @interactions = Interaction.find_subclass(params[:interaction_filter]).
      where(:program_id => current_program.id).
      limit(25).order(:interaction_time.desc)

    @interactions = @interactions.where(:person_id => params[:person_id]) if params[:person_id]

    respond_with @interactions
  end

  def create
    @person = current_scope.people.find(params[:person_id])
    @interaction = Interaction.
    find_subclass(params[:type]).
    new(params[:interaction])
    @interaction.person = @person
    @interaction.user = current_user

    if @interaction.save
      interactions = @interaction.execute(:request => request)
      content_form = render_cell :interaction, :form, :interaction => @interaction.class.new(:person => @person)
      content_feed = interactions.map do |interaction|
        new_interaction_feed(interaction,@person)
      end.join
    else
      content_form = render_cell :interaction, :form, :interaction => @interaction
    end

    content = {"form" => content_form, "feed" => content_feed }
    render(:json => {:html => content}.to_json)
  end

  def update
    @person = current_scope.people.find(params[:person_id])
    @interaction = @person.interactions.find(params[:id])

    content_interaction_id = @interaction.id
    @interaction[:updated_by_form] = true
    if @interaction.update_attributes(params[:interaction])
      content_feed = render_cell :interaction, :list_item, :interaction => @interaction, :person => @person
    else
      content_form = render_cell :interaction, :form, :interaction => @interaction
    end

    content = {"form" => content_form, "feed" => content_feed, "interaction_id" => content_interaction_id }
    render(:json => {:html => content}.to_json)
  end

  def dismiss
    if current_user.accounts.include? current_account
      @interaction = current_scope.interactions.find(params[:id])
      @interaction.reviewed_at = Time.now
      @interaction.reviewed_by = current_user
      render(:json => @interaction.save)
    else
      render(:json => false)
    end
  end

  def create_with_api
    @person = current_scope.people.find(params[:person_id])
    @interaction = Interaction.
    find_subclass(params[:type]).
    new(params[:interaction])
    @interaction.person = @person
    @interaction.user = current_user

    @interaction.execute(:request => request) if @interaction.save

    respond_with @interaction do |format|
      format.json { render :json => @interaction.to_json }
    end
  end

  def destroy
    current_scope.interactions.find(params[:id]).destroy

    redirect_to request.referer
  end

  def new_interaction_feed(interaction,recruit)
    content_tag(:li, (render_cell :interaction, :list_item, :interaction => interaction, :person => recruit), :id => "interaction_#{interaction.id}")
  end
end
