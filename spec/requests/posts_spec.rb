require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user)       { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let(:post_record) { FactoryBot.create(:post, user: user) }

  # GeminiServiceをstubで差し替え（全テストで共通）
  before do
    gemini_double = instance_double(GeminiService)
    allow(GeminiService).to receive(:new).and_return(gemini_double)
    allow(gemini_double).to receive(:call).and_return("AIが生成した整理文章")
  end

  # ----------------------------------------------------------------
  # 他ユーザーの投稿へのアクセス
  # ----------------------------------------------------------------
  describe "他ユーザーの投稿へのアクセス" do
    before { sign_in other_user }

    it "GETのshowにアクセスできないこと" do
      get post_path(post_record)
      expect(response).to have_http_status(:not_found)
    end

    it "GETのeditにアクセスできないこと" do
      get edit_post_path(post_record)
      expect(response).to have_http_status(:not_found)
    end

    it "PATCHのupdateができないこと" do
      patch post_path(post_record), params: { post: { thinking_topic: "変更" } }
      expect(response).to have_http_status(:not_found)
    end

    it "DELETEのdestroyができないこと" do
      delete post_path(post_record)
      expect(response).to have_http_status(:not_found)
    end
  end

  # ----------------------------------------------------------------
  # 未ログイン時のリダイレクト確認
  # ----------------------------------------------------------------
  describe "未ログイン時" do
    it "GET /posts は未ログインページへリダイレクトする" do
      get posts_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "GET /posts/new は未ログインページへリダイレクトする" do
      get new_post_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "GET /posts/:id/edit は未ログインページへリダイレクトする" do
      get edit_post_path(post_record)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "PATCH /posts/:id は未ログインページへリダイレクトする" do
      patch post_path(post_record), params: { post: { thinking_topic: "変更" } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "POST /posts/generate_summary は未ログインページへリダイレクトする" do
      post generate_summary_posts_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  # ----------------------------------------------------------------
  # ログイン済み
  # ----------------------------------------------------------------
  describe "ログイン済み" do
    before { sign_in user }

    # --- new ---
    describe "GET /posts/new" do
      it "200を返す" do
        get new_post_path
        expect(response).to have_http_status(:ok)
      end
    end

    # --- create ---
    describe "POST /posts" do
      let(:valid_params) do
        {
          post: {
            thinking_topic:    "テーマ",
            thinking_diffusion: "箇条書き",
            thinking_core:     "【壁打ち】 モヤモヤしていることを言語化してほしい",
            thinking_output:   nil
          }
        }
      end

      context "有効なパラメータの場合" do
        it "Postが1件増える" do
          expect {
            post posts_path, params: valid_params
          }.to change(Post, :count).by(1)
        end

        it "new_post_pathへリダイレクトする" do
          post posts_path, params: valid_params
          expect(response).to redirect_to(new_post_path)
        end
      end

      context "無効なパラメータの場合" do
        it "422を返す" do
          post posts_path, params: { post: { thinking_topic: "" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "PATCH /posts/:id" do
      context "有効なパラメータの場合" do
        it "投稿が更新される" do
          patch post_path(post_record), params: { post: { thinking_topic: "更新後テーマ" } }
          expect(post_record.reload.thinking_topic).to eq("更新後テーマ")
        end

        it "post_pathへリダイレクトする" do
          patch post_path(post_record), params: { post: { thinking_topic: "更新後テーマ" } }
          expect(response).to redirect_to(post_path(post_record))
        end
      end

      context "無効なパラメータの場合" do
        it "422を返す" do
          patch post_path(post_record), params: { post: { thinking_topic: "" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    # --- generate_summary（生成と保存の分離） ---
    describe "POST /posts/generate_summary" do
      let(:ai_params) do
        {
          post: {
            thinking_topic:     "テーマ",
            thinking_diffusion: "箇条書き",
            thinking_core:      "【壁打ち】 モヤモヤしていることを言語化してほしい"
          }
        }
      end

      it "turbo_streamでAIの生成結果を返す" do
        post generate_summary_posts_path, params: ai_params,
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include("AIが生成した整理文章")
      end
    end

    # --- destroy ---
    describe "DELETE /posts/:id" do
      it "Postが1件減る" do
        post_record # 事前に作成
        expect {
          delete post_path(post_record)
        }.to change(Post, :count).by(-1)
      end

      it "posts_pathへリダイレクトする" do
        delete post_path(post_record)
        expect(response).to redirect_to(posts_path)
      end
    end
  end
end
