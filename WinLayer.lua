--
-- Author: zhaoyaopu
-- Date: 2015-06-05 08:53:25
--
local WinLayer = class("WinScene", function()
	return display.newColorLayer(cc.c4b(100, 100, 100, 100))
end)

function WinLayer:ctor()
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(true)
	self:setContentSize(cc.size(display.width,display.height))
	self:init()
end

function WinLayer:init()
	local scenenum = ModifyData.getSceneNumber()
	local chapternum = ModifyData.getChapterNumber()
	-- 星星数
	local starnum = ModifyData.getStarNumber()

	local tb = PublicData.SCENETABLE

	-- 胜利面板
	local sp = display.newSprite("succeed.png")
	sp:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
	self:addChild(sp)

	-- 胜利音效
	if SetLayer.isPlaySound then
		audio.playSound("win.wav",false)
	end

	-- 胜利粒子效果	
	self._quad = cc.ParticleSystemQuad:create("xingxing.plist")
	self._quad:setPosition(cc.p(display.cx,display.cy+50))
	self._quad:setDuration(2)
	self:addChild(self._quad)

	-- 判断场景中关卡是否全部通过
	if chapternum == #Data.SCENE[scenenum] and starnum == 3 then
		local label = display.newTTFLabel({
			text = "恭喜您，此场景已全部通关",
			size = 30,
			color = cc.c3b(100, 100, 200),
			align = cc.TEXT_ALIGNMENT_LEFT,
			valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP})
		label:setPosition(cc.p(display.cx,display.cy+100))
		self:addChild(label)
	end

	-- 星星
	for i=1,starnum do
 		local sp = display.newSprite("star2.png")
 		sp:setPosition(cc.p(self:getContentSize().width/2-100+50*i,self:getContentSize().height/2+20))
 		sp:setScale(1.2)
 		self:addChild(sp)
 	end

	local function click(event)
		local tag = event.target:getTag()
		-- 重玩
		if 1 == tag then
			display.replaceScene(GameScene.new())
		-- 下一关
		elseif 2 == tag then
			if chapternum < #tb[scenenum] then
				-- 判断下一关卡是否解锁
				if 0 == tb[scenenum][chapternum+1].lock then
					ModifyData.setChapterNumber(chapternum+1)
					display.replaceScene(GameScene.new())
				else
					-- 星星数小于3，不能进行下一关
					if starnum < 3 then
						local label = display.newTTFLabel({
							text = "您需要获得三颗星星来解锁下一关",
							size = 30,
							color = cc.c3b(100, 100, 200),
							align = cc.TEXT_ALIGNMENT_LEFT,
							valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP
							})
						label:setPosition(cc.p(display.cx,display.cy+100))
						self:addChild(label)
					else
						ModifyData.setChapterNumber(chapternum+1)
						display.replaceScene(GameScene.new())
					end
				end
			end
		-- 菜单
		elseif 3 == tag then
			display.replaceScene(SelectChapter.new())
		end
	end

	local anode = display.newNode()
	anode:pos(display.cx, 200)
	self:addChild(anode)

	local item1 = cc.ui.UIPushButton.new({
		normal = "again.png",},
		{scale9 = true})
	:onButtonClicked(click)
	:pos(-100, 0)
	:addTo(anode)

	local item2 = cc.ui.UIPushButton.new({
		normal = "next.png"},
		{scale9 = true})
	:onButtonClicked(click)
	:pos(0, 0)
	:addTo(anode)

	local item3 = cc.ui.UIPushButton.new({
		normal = "menu.png"},
		{scale9 = true})
	:onButtonClicked(click)
	:pos(100, 0)
	:addTo(anode)

	item1:setTag(1)
	item2:setTag(2)
	item3:setTag(3)

	item1:setScale(1.3)
	item2:setScale(1.3)
	item3:setScale(1.3)

	-- 章节最后一个关卡时,移除下一关按钮
	if chapternum == #Data.SCENE[scenenum] then
		item2:removeSelf()
	end
end

return WinLayer