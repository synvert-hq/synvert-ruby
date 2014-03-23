require 'spec_helper'

describe 'rails strong_parameters snippet' do
  before do
    Synvert::Configuration.instance.set :path, '.'
    rewriter_path = File.join(File.dirname(__FILE__), '../../../../lib/synvert/snippets/rails/strong_parameters.rb')
    @rewriter = eval(File.read(rewriter_path))
    allow_any_instance_of(Synvert::Rewriter::GemSpec).to receive(:match?).and_return(true)
  end

  describe 'with fakefs', fakefs: true do
    let(:application_content) {'''
module Synvert
  class Application < Rails::Application
    config.active_record.whitelist_attributes = true
    config.active_record.mass_assignment_sanitizer = :strict
  end
end
    '''}
    let(:application_rewritten_content) {'''
module Synvert
  class Application < Rails::Application
  end
end
    '''}
    let(:post_model_content) {'''
class Post < ActiveRecord::Base
  attr_accessible :title, :description
end
    '''}
    let(:post_model_rewritten_content) {'''
class Post < ActiveRecord::Base
end
    '''}
    let(:posts_controller_content) {'''
class PostsController < ApplicationController
  def update
    @post = Post.find(params[:id])
    if @post.update_attributes params[:post]
      redirect_to post_path(@post)
    else
      render :action => :edit
    end
  end
end
    '''}
    let(:posts_controller_rewritten_content) {'''
class PostsController < ApplicationController
  def update
    @post = Post.find(params[:id])
    if @post.update_attributes post_params
      redirect_to post_path(@post)
    else
      render :action => :edit
    end
  end

  def post_params
    params.require(:post).permit(:title, :description)
  end
end
    '''}

    it 'process' do
      FileUtils.mkdir_p 'config'
      FileUtils.mkdir_p 'app/models'
      FileUtils.mkdir_p 'app/controllers'
      File.write 'config/application.rb', application_content
      File.write 'app/models/post.rb', post_model_content
      File.write 'app/controllers/posts_controller.rb', posts_controller_content
      @rewriter.process
      expect(File.read 'config/application.rb').to eq application_rewritten_content
      expect(File.read 'app/models/post.rb').to eq post_model_rewritten_content
      expect(File.read 'app/controllers/posts_controller.rb').to eq posts_controller_rewritten_content
    end
  end
end
