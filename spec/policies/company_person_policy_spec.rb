require 'rails_helper'

RSpec.describe CompanyPersonPolicy do
  subject { described_class }

  let(:agency) { FactoryBot.create(:agency, name: 'Metplus') }
  let(:another_agency) { FactoryBot.create(:agency) }
  let(:company) { FactoryBot.create(:company, agencies: [agency]) }
  let!(:company_bayer) do
    FactoryBot.create(:company, name: 'Bayer-Raynor',
                                agencies: [another_agency])
  end

  let(:cp) { FactoryBot.create(:company_person, company: company) }
  let(:ca) { FactoryBot.create(:company_admin, company: company) }
  let(:cc)     { FactoryBot.create(:company_contact) }

  let(:admin)  { FactoryBot.create(:agency_admin, agency: agency) }
  let(:jd) { FactoryBot.create(:job_developer, agency: agency) }
  let(:cm) { FactoryBot.create(:case_manager, agency: agency) }
  let(:ap) { FactoryBot.create(:agency_person, agency: agency) }

  let(:ca_bayer) { FactoryBot.create(:company_admin, company: company_bayer) }
  let(:admin_bayer) { FactoryBot.create(:agency_admin, agency: another_agency) }
  let(:ap_bayer) { FactoryBot.create(:agency_person, agency: another_agency) }

  let(:js) { FactoryBot.create(:job_seeker) }

  permissions :edit?, :update?, :destroy? do
    it 'grants access to company admin of the same company' do
      expect(subject).to permit(ca, cp)
    end

    it 'denies access to company admin of a different company' do
      expect(subject).not_to permit(ca_bayer, cp)
    end

    it 'grants access to agency admin related to the company' do
      expect(subject).to permit(admin, cp)
    end

    it 'denies access to agency admin unrelated to the company' do
      expect(subject).not_to permit(admin_bayer, cp)
    end

    it 'denies access to job developer, company contact and job seeker' do
      expect(subject).not_to permit(jd, cp)
      expect(subject).not_to permit(cc, cp)
      expect(subject).not_to permit(js, cp)
    end
  end

  permissions :show? do
    it 'grants access to agency person related to the company' do
      expect(subject).to permit(cm, cp)
    end

    it 'grants access to company admin related to the company' do
      expect(subject).to permit(ca, cp)
    end

    it 'denies access to company admin and agency person unrelated to the company' do
      expect(subject).not_to permit(ca_bayer, cp)
      expect(subject).not_to permit(ap_bayer, cp)
    end

    it 'denies access to company contact and job seeker' do
      expect(subject).not_to permit(cc, cp)
      expect(subject).not_to permit(js, cp)
    end
  end

  permissions :home? do
    it 'grants access to agency admin related to the company' do
      expect(subject).to permit(admin, cp)
    end

    it 'denies access to job developer and case manager' do
      expect(subject).not_to permit(jd, cp)
      expect(subject).not_to permit(cm, cp)
    end

    it 'grants access to company people belong to the company' do
      expect(subject).to permit(ca, cp)
      expect(subject).to permit(cp, cp)
    end

    it 'denies access to agency admin unrelated to the company' do
      expect(subject).not_to permit(admin_bayer, cp)
    end

    it 'denies access to company people who do not belong to the company' do
      expect(subject).not_to permit(ca_bayer, cp)
    end

    it 'denies access to job seeker' do
      expect(subject).not_to permit(js, cp)
    end
  end

  permissions :edit_profile?, :update_profile? do
    it 'denies access if user is not a company person' do
      expect(subject).not_to permit(admin, cp)
      expect(subject).not_to permit(js, cp)
    end

    it 'denies access if user is a company person but not the right edit target' do
      expect(subject).not_to permit(ca, ca_bayer)
      expect(subject).not_to permit(ca, cp)
    end

    it 'allows access to company person if the edit target is the same user' do
      expect(subject).to permit(ca, ca)
      expect(subject).to permit(cp, cp)
    end
  end
end
