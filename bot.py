from aiogram import Bot, Dispatcher, types, executor
import asyncio
from database import init_user_db, get_user_by_id, save_user_data
from cloudflare_api import get_main_domains
import os

API_TOKEN = os.getenv("BOT_TOKEN")
CHANNEL_ID = -1001234567890
GROUP_ID = -1009876543210

bot = Bot(token=API_TOKEN)
dp = Dispatcher(bot)

init_user_db()

@dp.message_handler(commands=['start', 'menu'])
async def start(msg: types.Message):
    user_id = msg.from_user.id
    member_channel = await bot.get_chat_member(CHANNEL_ID, user_id)
    member_group = await bot.get_chat_member(GROUP_ID, user_id)

    if member_channel.status in ['left', 'kicked'] or member_group.status in ['left', 'kicked']:
        await msg.answer("❌ Kamu belum join ke channel atau grup!
Gabung dulu:
@freenetlite
@litechatgroup")
        return

    user = get_user_by_id(user_id)
    if not user:
        await msg.answer("🔐 Masukkan email Cloudflare kamu:")
        return

    await msg.answer("✅ Selamat datang! Gunakan /kelola untuk kelola domainmu.")

@dp.message_handler(lambda m: '@' in m.text)
async def input_email(msg: types.Message):
    user_id = msg.from_user.id
    save_user_data(user_id, msg.text, '')
    await msg.answer("Sekarang kirimkan API Key kamu.")

@dp.message_handler(lambda m: len(m.text) > 20 and not get_user_by_id(m.from_user.id)[2])
async def input_apikey(msg: types.Message):
    user_id = msg.from_user.id
    user = get_user_by_id(user_id)
    if user:
        save_user_data(user_id, user[1], msg.text)
        await msg.answer("🔍 Memindai domain...")
        domains = get_main_domains(user[1], msg.text)
        await msg.answer("✅ Ditemukan domain:
" + "\n".join(domains))

if __name__ == '__main__':
    executor.start_polling(dp)