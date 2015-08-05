require 'hwping/handler'
require 'hwping/config'

describe HWPing::Handler do

  let(:launcher) { double() }
  let(:event) { double() }
  let(:config) do
    HWPing::Config.new(
      'server'   => 'irc.freenode.net',
      'port'     => 6667,
      'nick'     => 'hwping',
      'channels' => ['hwping-test'],
      'auth'     => ['auth_nick'],
      'targets'  => {
        'target_nick_1' => [120, 340],
        'target_nick_2' => [410, 680]
      }
    )
  end

  subject { described_class.new(launcher, config) }

  before do
    allow(event).to receive(:user).and_return(nick)
  end

  context 'from unauthorized nick' do
    let(:nick) {'unauth_nick'}

    describe 'channel message' do
      let(:response) { subject.channel(event) }

      it 'beginning with hwping' do
        expect(event).to receive(:message).and_return('hwping something unimportant')
        expect(response).to eq(:unauthorized)
      end

      it 'not beginning with hwping' do
        expect(event).to receive(:message).and_return('something unimportant')
        expect(response).to be_nil
      end
    end

    describe 'private message' do
      let(:response) { subject.private(event) }

      it 'with any content' do
        expect(response).to eq([:unauthorized])
      end
    end
  end

  context 'from authorized nick' do
    let(:nick) {'auth_nick'}

    describe 'channel message' do
      let(:response) { subject.channel(event) }

      it 'beginning with hwping combined with an existing target' do
        expect(event).to receive(:message).and_return('hwping target_nick_1')
        expect(launcher).to receive(:point_and_fire).with([120, 340])
        expect(response).to eq(:firing)
      end

      it 'beginning with hwping combined with a non-existing target' do
        expect(event).to receive(:message).and_return('hwping target_nick_3')
        expect(response).to eq(:notarget)
      end

      it 'not beginning with hwping' do
        expect(event).to receive(:message).and_return('something unimportant')
        expect(response).to be_nil
      end
    end

    describe 'private message' do
      let(:response) { subject.private(event) }
      let(:list) { subject.private(event) }

      it 'fire' do
        expect(event).to receive(:message).and_return('fire')
        expect(launcher).to receive(:fire)
        expect(response).to eq([:fire])
      end

      it 'reset' do
        expect(event).to receive(:message).and_return('reset')
        expect(launcher).to receive(:reset)
        expect(response).to eq([:reset])
      end

      it 'position' do
        expect(event).to receive(:message).and_return('position')
        expect(launcher).to receive(:position).and_return([200, 300])
        expect(response).to eq([:position, 200, 300])
      end

      it 'help' do
        expect(event).to receive(:message).and_return('help')
        expect(response).to eq([:help])
      end

      it 'target list' do
        expect(event).to receive(:message).and_return('target list')
        expect(response).to eq([:target_list, 'target_nick_1, target_nick_2'])
      end

      it 'target get existing target' do
        expect(event).to receive(:message).and_return('target get target_nick_1')
        expect(response).to eq([:target_get, 120, 340])
      end

      it 'target get non-existing target' do
        expect(event).to receive(:message).and_return('target get target_nick_3')
        expect(response).to eq([:notarget])
      end

      it 'target set with explicit position' do
        expect(event).to receive(:message).and_return('target set target_nick_3 210 320')
        expect(response).to eq([:target_set, 210, 320])
        expect(event).to receive(:message).and_return('target list')
        expect(list).to eq([:target_list, "target_nick_1, target_nick_2, target_nick_3"])
      end

      it 'target set with no position' do
        expect(event).to receive(:message).and_return('target set target_nick_3')
        expect(launcher).to receive(:position).and_return([210, 320])
        expect(response).to eq([:target_set, 210, 320])
        expect(event).to receive(:message).and_return('target list')
        expect(list).to eq([:target_list, "target_nick_1, target_nick_2, target_nick_3"])
      end

      it 'target del existing target' do
        expect(event).to receive(:message).and_return('target del target_nick_2')
        expect(response).to eq([:target_del])
        expect(event).to receive(:message).and_return('target list')
        expect(list).to eq([:target_list, "target_nick_1"])
      end

      it 'target del non-existing target' do
        expect(event).to receive(:message).and_return('target del target_nick_3')
        expect(response).to eq([:notarget])
      end

      it 'move launcher up' do
        expect(event).to receive(:message).and_return('up 200')
        expect(launcher).to receive(:up).with(200)
        expect(response).to eq([:move])
      end

      it 'move launcher down' do
        expect(event).to receive(:message).and_return('down 100')
        expect(launcher).to receive(:down).with(100)
        expect(response).to eq([:move])
      end

      it 'move launcher left' do
        expect(event).to receive(:message).and_return('left 400')
        expect(launcher).to receive(:left).with(400)
        expect(response).to eq([:move])
      end

      it 'move launcher right' do
        expect(event).to receive(:message).and_return('right 500')
        expect(launcher).to receive(:right).with(500)
        expect(response).to eq([:move])
      end

      it 'invalid message' do
        expect(event).to receive(:message).and_return('some invalid message')
        expect(response).to eq([:badcommand])
      end
    end
  end

  context 'from authorized nick with set mod' do
    let(:nick) {'auth_nick|afk'}

    describe 'channel message' do
      let(:response) { subject.channel(event) }

      it 'beginning with hwping combined with an existing target' do
        expect(event).to receive(:message).and_return('hwping target_nick_1')
        expect(launcher).to receive(:point_and_fire).with([120, 340])
        expect(response).to eq(:firing)
      end

      it 'beginning with hwping combined with a non-existing target' do
        expect(event).to receive(:message).and_return('hwping target_nick_3')
        expect(response).to eq(:notarget)
      end

      it 'not beginning with hwping' do
        expect(event).to receive(:message).and_return('something unimportant')
        expect(response).to be_nil
      end
    end
  end
end
