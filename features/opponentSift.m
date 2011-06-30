function features = opponentSift(I, imageFName, params)
	features = genSift(I, imageFName, params, 'opponenthistogram');
end
