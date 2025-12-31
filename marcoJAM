panicBtn.MouseButton1Click:Connect(function()
	-- MISC MODS
	espBtn.Text = "ESP: OFF"
	flyBtn.Text = "Fly: OFF"
	noclipBtn.Text = "Noclip: OFF"
	gravBtn.Text = "Gravity: 50"
	tracersBtn.Text = "Tracers: OFF"
	flyEnabled = false
	noclipEnabled = false
	tracersEnabled = false
	-- Reset gravity
	if humanoid then
		humanoid.UseJumpPower = true
		humanoid.JumpPower = 50
	end

	-- FUN MODS
	spinBtn.Text = "Spin: OFF"
	bigHeadBtn.Text = "BigHead: OFF"
	confettiBtn.Text = "Confetti: OFF"
	rainbowTrailBtn.Text = "RainbowTrail: OFF"
	swimBtn.Text = "Swim: OFF"
	spinEnabled = false
	bigHeadEnabled = false
	confettiEnabled = false
	rainbowTrailEnabled = false
	swimEnabled = false
	if trail then trail:Destroy() end

	-- TROLL MODS
	spookBox.Visible = false
	headSitBox.Visible = false
	fakeDeathBtn.Text = "Fake Death" -- no toggle needed
	headSitBtn.Text = "HeadSit"

	-- Remove any temporary objects (BodyVelocity, BodyGyro, etc.)
	if flyBV then flyBV:Destroy() end
	if flyBG then flyBG:Destroy() end
	if swimBV then swimBV:Destroy() end
	if swimBG then swimBG:Destroy() end
	if root:FindFirstChild("HeadSitWeld") then
		root.HeadSitWeld:Destroy()
		humanoid.Sit = false
	end
end)
