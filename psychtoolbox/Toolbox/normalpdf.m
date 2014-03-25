function p = normalpdf(x,mu,sigma,norm)
%  [p] = normalpdf(x,[mu],[sigma],[norm])

if nargin < 4, norm = true; end
if nargin < 3, sigma = 1; end
if nargin < 2, mu = 0; end
if nargin < 1, error('Not enough input arguments.'); end

p = exp(-0.5*((x-mu)./sigma).^2);
if norm, p = p./(sqrt(2*pi).*sigma); end

end