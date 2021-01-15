class CommentsController < ApplicationController
  before_action :authenticate_user!
  
  def create 
    @comment = current_user.comments.build(comment_params)
    @comment.micropost_id = params[:micropost_id]
    @comment_micropost = @comment.micropost
    if @comment.save
      @comment_micropost.create_notification_comment!(current_user, @comment.id)
      flash[:success] = 'Comment sent!'
      redirect_to @comment.micropost
    else
      @micropost = Micropost.find(params[:micropost_id])  
      @comments = @micropost.comments
      render 'microposts/show'
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    flash[:success] = 'Deleted comment.'
    redirect_to @comment.micropost
  end
  
  private

  def comment_params
    params.require(:comment).permit(:content)
  end
  
end