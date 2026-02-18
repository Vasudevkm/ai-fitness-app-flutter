String calculateLevel(int experienceYears) {
  if (experienceYears < 1) {
    return "Beginner";
  } else if (experienceYears < 3) {
    return "Intermediate";
  } else {
    return "Advanced";
  }
}
