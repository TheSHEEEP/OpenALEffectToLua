// Apply random effect
char* effects[%num_entries%] = { %entries% };
int rndValue = Ogre::Math::RangeRandom(1.0f, %num_entries%.0f) + 0.5f;
std::string effectName = effects[rndValue];
CONSOLE_LOG(effectName);
getSoundModule()->getEmitter()->setEnvironmentID(effectName);