# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130728010225) do

  create_table "slashdot_postings", force: true do |t|
    t.string   "title"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site"
    t.string   "author"
    t.integer  "comment_count"
    t.string   "post_date"
  end

  create_table "slashdot_postings_urls", id: false, force: true do |t|
    t.integer "slashdot_posting_id"
    t.integer "url_id"
  end

  add_index "slashdot_postings_urls", ["slashdot_posting_id", "url_id"], name: "index_slashdot_postings_urls_on_slashdot_posting_id_and_url_id"

  create_table "urls", force: true do |t|
    t.text     "target_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
