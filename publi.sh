CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TEMP_BRANCH=$(date +%s.%N | md5sum | cut -d ' ' -f 1)
if [ "$TRAVIS" == true ]; then
  CURRENT_BRANCH="$TRAVIS_BRANCH"
  echo "TRAVIS_SECURE_ENV_VARS=$TRAVIS_SECURE_ENV_VARS"
  echo "TRAVIS_PULL_REQUEST=$TRAVIS_PULL_REQUEST"
  echo "TRAVIS_BRANCH=$TRAVIS_BRANCH"
  [ "$TRAVIS_SECURE_ENV_VARS" == true -a "$TRAVIS_PULL_REQUEST" == false -a "$TRAVIS_BRANCH" == master ] || exit 1
  [ -n "$encrypted_9bed05110d64_key" -a -n "$encrypted_9bed05110d64_iv" ] || (echo "Travis CI decryption keys not found"; exit 1)
  openssl aes-256-cbc -K "$encrypted_9bed05110d64_key" -iv "$encrypted_9bed05110d64_iv" -in github-deploy-key.enc -out github-deploy-key -d
  chmod 600 github-deploy-key
  eval "$(ssh-agent -s)"
  ssh-add github-deploy-key
  rm github-deploy-key
  git remote set-url --push origin "git@github.com:$TRAVIS_REPO_SLUG.git"
  git config --global user.email "contact@travis-ci.com"
  git config --global user.name "Travis CI"
  echo "Publishing to gh-pages"
fi
set -x
git checkout --orphan "$TEMP_BRANCH"
npm install
make
git reset .
git add -f index.html
git commit -m gh-pages
git push -f origin HEAD:gh-pages
git checkout -f "$CURRENT_BRANCH"
git branch -D "$TEMP_BRANCH"
