angular.module('loomioApp').directive 'activityCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/activity_card/activity_card.html'
  replace: true
  controller: ($scope, $rootScope, $location, $document, $timeout, Records, LoadingService) ->

    $scope.pageSize = 30
    $scope.firstLoadedSequenceId = 0
    $scope.lastLoadedSequenceId = 0
    $scope.lastReadSequenceId = $scope.discussion.reader().lastReadSequenceId
    visibleSequenceIds = []

    $scope.init = ->
      $scope.discussion.markAsRead(0)

      $scope.loadEventsForwards($scope.initialLoadSequenceId()).then ->
        $rootScope.$broadcast 'threadPageEventsLoaded'

    $scope.initialLoadSequenceId = ->
      if $scope.discussion.isUnread()
        $scope.discussion.reader().lastReadSequenceId - 1
      else
        $scope.discussion.lastSequenceId - $scope.pageSize + 1

    $scope.hasNewActivity = ->
      $scope.discussion.isUnread()

    $scope.beforeCount = ->
      $scope.firstLoadedSequenceId - $scope.discussion.firstSequenceId

    updateLastSequenceId = ->
      visibleSequenceIds = _.uniq(visibleSequenceIds)
      $rootScope.$broadcast('threadPosition', $scope.discussion, _.max(visibleSequenceIds))

    addSequenceId = (id) ->
      visibleSequenceIds.push(id)
      updateLastSequenceId()

    removeSequenceId = (id) ->
      visibleSequenceIds = _.without(visibleSequenceIds, id)
      updateLastSequenceId()

    $scope.threadItemHidden = (item) ->
      removeSequenceId(item.sequenceId)

    $scope.threadItemVisible = (item) ->
      addSequenceId(item.sequenceId)
      $scope.discussion.markAsRead(item.sequenceId)
      $scope.loadEventsForwards($scope.lastLoadedSequenceId) if $scope.loadMoreAfterReading(item)

    $scope.loadEvents = ({from, per}) ->
      from = 0 unless from?
      per = $scope.pageSize unless per?

      Records.events.fetchByDiscussion($scope.discussion.key, {from: from, per: per}).then ->
        $scope.firstLoadedSequenceId = Records.events.minLoadedSequenceIdByDiscussion($scope.discussion)
        $scope.lastLoadedSequenceId  = Records.events.maxLoadedSequenceIdByDiscussion($scope.discussion)

    $scope.loadEventsForwards = (sequenceId) ->
      $scope.loadEvents(from: sequenceId)
    LoadingService.applyLoadingFunction $scope, 'loadEventsForwards'

    $scope.loadEventsBackwards = ->
      lastPageSequenceId = _.max [$scope.firstLoadedSequenceId - $scope.pageSize, 0]
      $scope.loadEvents(from: lastPageSequenceId)
    LoadingService.applyLoadingFunction $scope, 'loadEventsBackwards'

    $scope.canLoadBackwards = ->
      $scope.firstLoadedSequenceId > $scope.discussion.firstSequenceId and
      !($scope.loadEventsForwardsExecuting or $scope.loadEventsBackwardsExecuting)

    $scope.loadMoreAfterReading = (item) ->
      item.sequenceId == $scope.lastLoadedSequenceId and
      item.sequenceId < $scope.discussion.lastSequenceId

    $scope.safeEvent = (kind) ->
      _.contains ['new_comment', 'new_motion', 'new_vote'], kind

    $scope.init()
    return
