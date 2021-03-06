#-- encoding: UTF-8
#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2020 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++
require_relative '../legacy_spec_helper'

describe Group, type: :model do
  before do
    @group = FactoryBot.create :group
    @member = FactoryBot.build :member
    @work_package = FactoryBot.create :work_package
    @roles = FactoryBot.create_list :role, 2
    @member.attributes = { principal: @group, role_ids: @roles.map(&:id) }
    @member.save!
    @project = @member.project
    @user = FactoryBot.create :user
    @group.users << @user
    @group.save!
  end

  it 'should create' do
    g = Group.new(lastname: 'New group')
    assert g.save
  end

  it 'should roles given to new user' do
    user = FactoryBot.build :user
    @group.users << user

    assert user.member_of? @project
  end

  it 'should roles given to existing user' do
    assert @user.member_of? @project
  end

  it 'should roles updated' do
    group = FactoryBot.create :group
    member = FactoryBot.build :member
    roles = FactoryBot.create_list :role, 2
    role_ids = roles.map(&:id)
    member.attributes = { principal: group, role_ids: role_ids }
    member.save!
    user = FactoryBot.create :user
    group.users << user
    group.save!

    member.role_ids = [role_ids.first]
    assert_equal [role_ids.first], user.reload.roles_for_project(member.project).map(&:id).sort

    member.role_ids = role_ids
    assert_equal role_ids, user.reload.roles_for_project(member.project).map(&:id).sort

    member.role_ids = [role_ids.last]
    assert_equal [role_ids.last], user.reload.roles_for_project(member.project).map(&:id).sort

    member.role_ids = [role_ids.first]
    assert_equal [role_ids.first], user.reload.roles_for_project(member.project).map(&:id).sort
  end

  it 'should roles removed when removing group membership' do
    assert @user.member_of?(@project)
    @member.destroy
    @user.reload
    @project.reload
    assert !@user.member_of?(@project)
  end

  it 'should roles removed when removing user from group' do
    assert @user.member_of?(@project)
    @user.groups.destroy_all
    @user.reload
    @project.reload
    assert !@user.member_of?(@project)
  end
end
