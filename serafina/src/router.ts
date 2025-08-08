import 'dotenv/config';
// Core Discord bot wiring. Bridges slash commands and text whispers to the VR layer.
// Using explicit intent flags so Discord gives us message content for routing.
import {
  Client,
  GatewayIntentBits,
  REST,
  Routes,
  SlashCommandBuilder,
  Events,
} from 'discord.js';
import fetch from 'node-fetch';
import { scheduleNightlyCouncilReport, runCouncilReport } from './nightlyReport.js';

const TOKEN = process.env.DISCORD_TOKEN || '';
const CLIENT_ID = process.env.CLIENT_ID || '';
const GUILD_ID = process.env.GUILD_ID || '';
const MCP = process.env.MCP_URL || '';
const COUNCIL_CH = process.env.CHN_COUNCIL || '';

// Register the slash command on startup.
// `/council report now` → manually trigger the nightly council report.
const rest = new REST({ version: '10' }).setToken(TOKEN);
const commands = [
  new SlashCommandBuilder()
    .setName('council')
    .setDescription('ShadowFlower council utilities')
    .addSubcommandGroup(group =>
      group
        .setName('report')
        .setDescription('Council reporting utilities')
        .addSubcommand(sub =>
          sub
            .setName('now')
            .setDescription('Post the nightly council report immediately')
        )
    )
].map(c => c.toJSON());

async function registerCommands() {
  try {
    await rest.put(Routes.applicationGuildCommands(CLIENT_ID, GUILD_ID), { body: commands });
    console.log('Slash commands registered');
  } catch (err) {
    console.error('Error registering commands', err);
  }
}

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ],
});

client.once(Events.ClientReady, () => {
  console.log(`Logged in as ${client.user?.tag}`);
  scheduleNightlyCouncilReport(client);
});

client.on(Events.InteractionCreate, async interaction => {
  if (!interaction.isChatInputCommand()) return;
  if (
    interaction.commandName === 'council' &&
    interaction.options.getSubcommandGroup() === 'report' &&
    interaction.options.getSubcommand() === 'now'
  ) {
    await interaction.reply({ content: 'Summoning council report…', ephemeral: true });
    await runCouncilReport(client);
  }
});

// Relay text whispers from the council channel into the VR layer via MCP /osc.
client.on(Events.MessageCreate, async msg => {
  if (msg.author.bot || msg.channelId !== COUNCIL_CH) return;
  if (!msg.content.startsWith('!')) return; // `!athena status`
  const [toRaw, ...rest] = msg.content.slice(1).split(' ');
  const to = toRaw || '*';
  const whisper = rest.join(' ').trim();
  if (!whisper || !MCP) return;

  try {
    await fetch(`${MCP}/osc`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ from: msg.author.username, to, message: whisper }),
    });
  } catch (err) {
    console.error('Failed to relay whisper', err);
  }
});

registerCommands().then(() => client.login(TOKEN));
