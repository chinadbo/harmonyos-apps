import router from '@ohos.router';

/** 跳转到题目详情页 */
export function openProblem(problemId: number): void {
  router.pushUrl({
    url: 'pages/ProblemDetail',
    params: { problemId: problemId }
  });
}
