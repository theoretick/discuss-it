# require 'spec_helper'
# require 'discuss_it_api'

# describe "discuss it api" do

#   before(:all) do
#     VCR.turn_on!
#     @discussit = DiscussItApi.new('http://jmoiron.net/blog/japanese-peer-peer/')
#     @washpo_nsachief = DiscussItApi.new('http://www.washingtonpost.com/world/national-security/for-nsa-chief-terrorist-threat-drives-passion-to-collect-it-all/2013/07/14/3d26ef80-ea49-11e2-a301-ea5a8116d211_story.html')
#     @restorefourth = DiscussItApi.new('www.restorethefourth.net/')
#   end

#   describe "initialization" do

#     it "should not initialize without an argument" do
#       expect{ DiscussItApi.new() }.to_not be_an_instance_of(DiscussItApi)
#     end

#     it "should initialize with 1 arg" do
#       expect(@discussit).to be_an_instance_of(DiscussItApi)
#     end

#     it "should not initialize with 2 args" do
#       expect {
#         DiscussItApi.new('http://example.com','http://example.org')
#       }.to raise_error(ArgumentError, "wrong number of arguments (2 for 1)")
#     end
#   end

#   describe "get_json", :vcr do

#     it "should raise error if given malformed URL" do
#       expect {
#         @discussit.get_json(
#         'http://www.reddit.com/api/info.json?url=',
#         '%')
#       }.to raise_error(DiscussItUrlError)
#     end

#     # it "should return parsed JSON if given valid URL" do
#     #   expect(@discussit.get_json('http://www.reddit.com/api/info.json?url=',
#     #     'example.com')).to eq(MOCK_RESPONSE)
#     # end

#   end

#   describe "format_url" do

#     it "should add 'http://' if not provided for reddit" do
#       expect(@discussit.format_url(:reddit, 'example.com')).to start_with('http://')
#     end

#     it "should add 'http://' if not provided for hn" do
#       expect(@discussit.format_url(:hn, 'example.com')).to start_with('http://')
#     end

#     it "should add trailing '/' if not provided for hn" do
#       expect(@discussit.format_url(:hn, 'http://example.com')).to eq('http://example.com/')
#     end

#     it "should NOT add trailing '/' if not provided for reddit" do
#       expect(@discussit.format_url(:reddit, 'http://example.com')).not_to eq('http://example.com/')
#     end

#   end

#   describe "parse_response" do

#     it "should return nil if passed an empty list" do
#       expect(@discussit.parse_response(:reddit,{})).to be_nil
#     end

#     # mocha this shit
#     #
#     # it "should get a correct substring from @discussit" do
#     #   expect(@discussit.parse_response(:reddit,)).to eql(
#     #     '/r/technology/comments/1hxl84/japans_anonymous_decentralized_p2p_networks_2008/')
#     # end
#   end

#   describe "find_all", :vcr do

#     it "should get 3-item array from @discussit find_all" do
#       expect(@discussit.find_all).to eq(
#         [
#           'http://www.reddit.com/r/technology/comments/1hxl84/japans_anonymous_decentralized_p2p_networks_2008/',
#           'http://www.reddit.com/r/darknetplan/comments/1hxkmt/japans_anonymous_decentralized_p2p_networks_2008/',
#           'http://news.ycombinator.com/item?id=6012405'
#         ])
#     end

#     it "should get 3-item array from @washpo_nsachief find_all" do
#       expect(@washpo_nsachief.find_all.length).to eq(6)
#       # expect(@washpo_nsachief.find_all).to eq(
#       #   [
#       #     'http://www.reddit.com/r/politics/comments/1ibmcu/for_nsa_chief_terrorist_threat_drives_passion_to/',
#       #     'http://www.reddit.com/r/EndlessWar/comments/1idfev/for_nsa_chief_terrorist_threat_drives_passion_to/',
#       #     'http://www.reddit.com/r/privacy/comments/1ibe5g/for_nsa_chief_terrorist_threat_drives_passion_to/',
#       #     'http://www.reddit.com/r/ModerationLog/comments/1ibo1v/rworldnews_spam_filtered_for_nsa_chief_terrorist/',
#       #     'http://www.reddit.com/r/POLITIC/comments/1ibmbv/for_nsa_chief_terrorist_threat_drives_passion_to/',
#       #     'http://www.reddit.com/r/TruthInPolitics/comments/1ibfsy/for_nsa_director_keith_alexander_terrorist_threat/',
#       #     'http://news.ycombinator.com/item?id=6043251'
#       #   ])
#     end

#     it "should get 27-item array from @restorefourth find_all" do
#       expect(@restorefourth.find_all.length).to eq(27)
#       # expect(@restorefourth.find_all).to eq(
#       #   [
#       #     'http://www.reddit.com/r/news/comments/1hn4cv/restore_the_fourth/',
#       #     'http://www.reddit.com/r/technology/comments/1hn4aq/restore_the_fourth/',
#       #     'http://www.reddit.com/r/news/comments/1hl3w4/west_virginia_is_the_only_state_without_a_restore/',
#       #     'http://www.reddit.com/r/politics/comments/1hhbzu/upset_about_the_nsa_scandal_and_feel_as_though/',
#       #     'http://www.reddit.com/r/news/comments/1hd0t1/if_the_nsa_listening_in_on_you_unnerves_you_join/',
#       #     'http://www.reddit.com/r/r4links/comments/1i3abd/test_post/',
#       #     'http://www.reddit.com/r/Libertarian/comments/1hn4dq/restore_the_fourth/',
#       #     'http://www.reddit.com/r/Campaigns/comments/1hmp38/restore_the_fourth_is_down_atm_load_ddos_or_what/',
#       #     'http://www.reddit.com/r/alaska/comments/1hl0u5/restore_the_fourth_in_alaska_none_planned_so_far/',
#       #     'http://www.reddit.com/r/misc/comments/1hlews/an_interactive_map_of_restore_the_fourth_protest/',
#       #     'http://www.reddit.com/r/PuertoRico/comments/1hlbv0/hey_puerto_rico_we_dont_seem_to_have_anything/',
#       #     'http://www.reddit.com/r/allentown/comments/1hll2k/why_no_allentown_or_lehigh_valley/',
#       #     'http://www.reddit.com/r/StLouis/comments/1hjton/hey_rstlouis_tired_of_the_nsas_recent_antics_then/',
#       #     'http://www.reddit.com/r/CitizensActionNet/comments/1hkjg3/restore_the_fourth_rally_in_a_city_near_you/',
#       #     'http://www.reddit.com/r/cincinnati/comments/1hijy1/cincinnati_needs_a_restore_the_fourth_rally/',
#       #     'http://www.reddit.com/r/Tucson/comments/1hilgg/restore_the_fourth_protest_tempe_july_4th_4pm/',
#       #     'http://www.reddit.com/r/Omaha/comments/1hipym/restore_the_fourth_anybody_wanna_get_this_going/',
#       #     'http://www.reddit.com/r/orangecounty/comments/1hg1lr/restore_the_4th/',
#       #     'http://www.reddit.com/r/Seattle/comments/1hdqws/protest_the_nsa_spying_saturday_july_6th_westlake/',
#       #     'http://www.reddit.com/r/ModerationLog/comments/1hefaz/rpolitics_spam_filtered_national_protest_link_for/',
#       #     'http://www.reddit.com/r/AsburyPark/comments/1hc44h/can_we_get_one_of_these_protests_going_on_the/',
#       #     'http://www.reddit.com/r/AnnArbor/comments/1gv8sb/just_letting_a2_know_about_the_nsa_protests_on/',
#       #     'http://www.reddit.com/r/POLITIC/comments/1gt0o3/july_4th_protest_brazil_cant_have_all_the_fun_are/',
#       #     'http://www.reddit.com/r/restorethefourth/comments/1hlctl/an_interactive_map_of_the_restore_the_fourth/',
#       #     'http://www.reddit.com/r/Denver/comments/1hia3g/on_july_4th_people_will_be_protesting_the_nsa_in/',
#       #     'http://news.ycombinator.com/item?id=5913146',
#       #     'http://news.ycombinator.com/item?id=5983835'
#       #   ])
#     end
#   end

#   describe "find_top", :vcr do

#     it "should get 2-item array from @discussit find_top" do
#       expect(@discussit.find_top).to eq(
#         [
#           'http://www.reddit.com/r/technology/comments/1hxl84/japans_anonymous_decentralized_p2p_networks_2008/',
#           'http://news.ycombinator.com/item?id=6012405'
#         ])
#     end

#     it "should get 2-item array from @washpo_nsachief find_top" do
#       expect(@washpo_nsachief.find_top).to eq(
#         [
#           'http://www.reddit.com/r/privacy/comments/1ibe5g/for_nsa_chief_terrorist_threat_drives_passion_to/',
#           'http://news.ycombinator.com/item?id=6043251'
#         ])
#     end

#     it "should get 2-item array from @restorefourth find_top" do
#       expect(@restorefourth.find_top).to eq(
#         [
#           'http://www.reddit.com/r/politics/comments/1hhbzu/upset_about_the_nsa_scandal_and_feel_as_though/',
#           'http://news.ycombinator.com/item?id=5913146'
#         ])
#     end

#   end

# end

