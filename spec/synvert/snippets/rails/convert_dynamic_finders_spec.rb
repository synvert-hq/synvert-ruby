require 'spec_helper'

describe 'Convert dynamic finders' do
  before do
    Synvert::Configuration.instance.set :path, '.'
    rewriter_path = File.join(File.dirname(__FILE__), '../../../../lib/synvert/snippets/rails/convert_dynamic_finders.rb')
    @rewriter = eval(File.read(rewriter_path))
    allow_any_instance_of(Synvert::Rewriter::GemSpec).to receive(:match?).and_return(true)
  end

  describe 'with fakefs', fakefs: true do
    let(:post_model_content) {'''
class Post < ActiveRecord::Base
  def active_users
    User.find_all_by_email_and_active(email, true)
    User.find_by_email_and_active(email, true)
    User.find_last_by_email_and_active(email, true)
    User.scoped_by_email_and_active(email, true)
    User.find_by_sql(["select * from  users where email = ?", email])
    User.find_by_id(id)
    User.find_by_account_id(Account.find_by_email(account_email).id)
    User.find_or_create_by_email_and_login(parmas)
    User.find_or_initialize_by_account_id(:account_id => account_id)
  end

  def self.active_admins
    find_all_by_role_and_active("admin", true)
  end
end
    '''}
    let(:post_model_rewritten_content) {'''
class Post < ActiveRecord::Base
  def active_users
    User.where(email: email, active: true)
    User.where(email: email, active: true).first
    User.where(email: email, active: true).last
    User.where(email: email, active: true)
    User.find_by_sql(["select * from  users where email = ?", email])
    User.find(id)
    User.where(account_id: Account.where(email: account_email).first.id).first
    User.find_or_create_by(parmas)
    User.find_or_initialize_by(:account_id => account_id)
  end

  def self.active_admins
    where(role: "admin", active: true)
  end
end
    '''}
    let(:users_controller_content) {'''
class UsersController < ApplicationController
  def new
    @user = User.find_or_initialize_by_login_and_email(params[:user][:login], params[:user][:email])
  end

  def create
    @user = User.find_or_create_by_login_and_email(params[:user][:login], params[:user][:email])
  end
end
    '''}
    let(:users_controller_rewritten_content) {'''
class UsersController < ApplicationController
  def new
    @user = User.find_or_initialize_by(login: params[:user][:login], email: params[:user][:email])
  end

  def create
    @user = User.find_or_create_by(login: params[:user][:login], email: params[:user][:email])
  end
end
    '''}

    it 'process' do
      FileUtils.mkdir_p 'app/models'
      FileUtils.mkdir_p 'app/controllers'
      File.write 'app/models/post.rb', post_model_content
      File.write 'app/controllers/users_controller.rb', users_controller_content
      @rewriter.process
      expect(File.read 'app/models/post.rb').to eq post_model_rewritten_content
      expect(File.read 'app/controllers/users_controller.rb').to eq users_controller_rewritten_content
    end
  end
end
