import React, { useState, useEffect } from 'react';
import { 
  Server, 
  Database, 
  Layers, 
  Activity, 
  Cloud, 
  Container,
  CheckCircle,
  AlertCircle,
  Loader,
  Users,
  BarChart3,
  Settings
} from 'lucide-react';

interface ServiceStatus {
  name: string;
  status: 'healthy' | 'warning' | 'error';
  uptime: string;
  requests: number;
  responseTime: number;
}

function App() {
  const [services, setServices] = useState<ServiceStatus[]>([
    {
      name: 'Frontend (React)',
      status: 'healthy',
      uptime: '2h 34m',
      requests: 1247,
      responseTime: 45
    },
    {
      name: 'Backend API (Node.js)',
      status: 'healthy',
      uptime: '2h 34m',
      requests: 3891,
      responseTime: 120
    },
    {
      name: 'PostgreSQL Database',
      status: 'healthy',
      uptime: '2h 34m',
      requests: 2156,
      responseTime: 15
    },
    {
      name: 'Redis Cache',
      status: 'healthy',
      uptime: '2h 34m',
      requests: 5432,
      responseTime: 3
    }
  ]);

  const [deploymentStatus, setDeploymentStatus] = useState<'deploying' | 'deployed' | 'failed'>('deployed');
  const [activeUsers, setActiveUsers] = useState(127);
  const [totalRequests, setTotalRequests] = useState(12734);

  useEffect(() => {
    // Simulate real-time updates
    const interval = setInterval(() => {
      setServices(prev => prev.map(service => ({
        ...service,
        requests: service.requests + Math.floor(Math.random() * 5),
        responseTime: service.responseTime + Math.floor(Math.random() * 10) - 5
      })));
      
      setActiveUsers(prev => prev + Math.floor(Math.random() * 3) - 1);
      setTotalRequests(prev => prev + Math.floor(Math.random() * 8));
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'healthy':
        return <CheckCircle className="w-5 h-5 text-green-500" />;
      case 'warning':
        return <AlertCircle className="w-5 h-5 text-yellow-500" />;
      case 'error':
        return <AlertCircle className="w-5 h-5 text-red-500" />;
      default:
        return <Loader className="w-5 h-5 text-gray-500 animate-spin" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'healthy':
        return 'bg-green-100 border-green-200 text-green-800';
      case 'warning':
        return 'bg-yellow-100 border-yellow-200 text-yellow-800';
      case 'error':
        return 'bg-red-100 border-red-200 text-red-800';
      default:
        return 'bg-gray-100 border-gray-200 text-gray-800';
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
      {/* Header */}
      <div className="bg-white/80 backdrop-blur-sm border-b border-gray-200/50 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-3">
              <div className="bg-gradient-to-r from-blue-600 to-purple-600 p-2 rounded-lg">
                <Container className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">DockerMasteryApp</h1>
                <p className="text-sm text-gray-600">Containerized Microservices on AWS</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                <span className="text-sm font-medium text-gray-700">
                  {deploymentStatus === 'deployed' ? 'Live on AWS ECS' : 'Deploying...'}
                </span>
              </div>
              <Settings className="w-5 h-5 text-gray-500 cursor-pointer hover:text-gray-700" />
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Overview */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white/70 backdrop-blur-sm rounded-xl p-6 border border-gray-200/50 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Active Users</p>
                <p className="text-2xl font-bold text-gray-900">{activeUsers.toLocaleString()}</p>
              </div>
              <div className="bg-blue-100 p-3 rounded-lg">
                <Users className="w-6 h-6 text-blue-600" />
              </div>
            </div>
          </div>
          
          <div className="bg-white/70 backdrop-blur-sm rounded-xl p-6 border border-gray-200/50 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Total Requests</p>
                <p className="text-2xl font-bold text-gray-900">{totalRequests.toLocaleString()}</p>
              </div>
              <div className="bg-green-100 p-3 rounded-lg">
                <BarChart3 className="w-6 h-6 text-green-600" />
              </div>
            </div>
          </div>
          
          <div className="bg-white/70 backdrop-blur-sm rounded-xl p-6 border border-gray-200/50 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Avg Response Time</p>
                <p className="text-2xl font-bold text-gray-900">
                  {Math.round(services.reduce((acc, s) => acc + s.responseTime, 0) / services.length)}ms
                </p>
              </div>
              <div className="bg-purple-100 p-3 rounded-lg">
                <Activity className="w-6 h-6 text-purple-600" />
              </div>
            </div>
          </div>
        </div>

        {/* Services Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {services.map((service, index) => (
            <div key={index} className="bg-white/70 backdrop-blur-sm rounded-xl p-6 border border-gray-200/50 shadow-sm">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center space-x-3">
                  {service.name.includes('Frontend') && (
                    <div className="bg-blue-100 p-2 rounded-lg">
                      <Layers className="w-5 h-5 text-blue-600" />
                    </div>
                  )}
                  {service.name.includes('Backend') && (
                    <div className="bg-green-100 p-2 rounded-lg">
                      <Server className="w-5 h-5 text-green-600" />
                    </div>
                  )}
                  {service.name.includes('Database') && (
                    <div className="bg-purple-100 p-2 rounded-lg">
                      <Database className="w-5 h-5 text-purple-600" />
                    </div>
                  )}
                  {service.name.includes('Redis') && (
                    <div className="bg-red-100 p-2 rounded-lg">
                      <Activity className="w-5 h-5 text-red-600" />
                    </div>
                  )}
                  <div>
                    <h3 className="font-semibold text-gray-900">{service.name}</h3>
                    <p className="text-sm text-gray-600">Uptime: {service.uptime}</p>
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  {getStatusIcon(service.status)}
                  <span className={`px-2 py-1 text-xs font-medium rounded-full border ${getStatusColor(service.status)}`}>
                    {service.status}
                  </span>
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div className="bg-gray-50 p-3 rounded-lg">
                  <p className="text-xs text-gray-600">Requests</p>
                  <p className="text-lg font-bold text-gray-900">{service.requests.toLocaleString()}</p>
                </div>
                <div className="bg-gray-50 p-3 rounded-lg">
                  <p className="text-xs text-gray-600">Response Time</p>
                  <p className="text-lg font-bold text-gray-900">{service.responseTime}ms</p>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* AWS Infrastructure */}
        <div className="bg-white/70 backdrop-blur-sm rounded-xl p-6 border border-gray-200/50 shadow-sm">
          <div className="flex items-center space-x-3 mb-6">
            <div className="bg-orange-100 p-2 rounded-lg">
              <Cloud className="w-5 h-5 text-orange-600" />
            </div>
            <div>
              <h3 className="font-semibold text-gray-900">AWS Infrastructure</h3>
              <p className="text-sm text-gray-600">ECS Cluster with Auto Scaling</p>
            </div>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="bg-gradient-to-r from-blue-500 to-blue-600 text-white p-4 rounded-lg">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm opacity-90">ECS Tasks</p>
                  <p className="text-2xl font-bold">4/4</p>
                </div>
                <Container className="w-8 h-8 opacity-80" />
              </div>
            </div>
            
            <div className="bg-gradient-to-r from-green-500 to-green-600 text-white p-4 rounded-lg">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm opacity-90">Load Balancer</p>
                  <p className="text-2xl font-bold">Active</p>
                </div>
                <Activity className="w-8 h-8 opacity-80" />
              </div>
            </div>
            
            <div className="bg-gradient-to-r from-purple-500 to-purple-600 text-white p-4 rounded-lg">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm opacity-90">RDS Instance</p>
                  <p className="text-2xl font-bold">Running</p>
                </div>
                <Database className="w-8 h-8 opacity-80" />
              </div>
            </div>
            
            <div className="bg-gradient-to-r from-red-500 to-red-600 text-white p-4 rounded-lg">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm opacity-90">ElastiCache</p>
                  <p className="text-2xl font-bold">Online</p>
                </div>
                <Layers className="w-8 h-8 opacity-80" />
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-8 text-center">
          <p className="text-sm text-gray-600">
            Deployed on AWS ECS with auto-scaling, load balancing, and monitoring
          </p>
        </div>
      </div>
    </div>
  );
}

export default App;