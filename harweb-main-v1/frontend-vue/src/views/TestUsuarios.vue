<template>
  <div class="min-h-full bg-gradient-to-br from-blue-50 via-white to-indigo-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Header -->
      <div class="bg-white shadow-lg rounded-xl mb-8 overflow-hidden">
        <div class="px-8 py-6" style="background: linear-gradient(135deg, #3B82F615 0%, #3B82F625 100%)">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center">
              <div class="w-16 h-16 bg-blue-100 rounded-xl flex items-center justify-center mr-6">
                <i class="fas fa-users text-3xl text-blue-600"></i>
              </div>
              <div>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">
                  👥 Test de Usuarios
                </h1>
                <p class="text-lg text-gray-600">
                  Prueba de conexión real con base de datos PostgreSQL
                </p>
              </div>
            </div>
            
            <!-- Estado de conexión -->
            <div class="flex items-center">
              <div class="flex items-center px-4 py-2 rounded-full" :class="connectionStatusClass">
                <div class="w-2 h-2 rounded-full mr-2" :class="connectionDotClass"></div>
                <span class="text-sm font-medium">{{ connectionStatus }}</span>
              </div>
            </div>
          </div>
          
          <!-- Botones de acción -->
          <div class="flex space-x-4">
            <button 
              @click="testConnection" 
              :disabled="loading"
              class="bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white px-6 py-2 rounded-lg transition-colors duration-200 inline-flex items-center"
            >
              <i class="fas fa-plug mr-2"></i>
              {{ loading ? 'Probando...' : 'Probar Conexión' }}
            </button>
            
            <button 
              @click="loadUsers" 
              :disabled="loading"
              class="bg-green-600 hover:bg-green-700 disabled:bg-green-400 text-white px-6 py-2 rounded-lg transition-colors duration-200 inline-flex items-center"
            >
              <i class="fas fa-sync-alt mr-2" :class="{ 'animate-spin': loading }"></i>
              {{ loading ? 'Cargando...' : 'Cargar Usuarios' }}
            </button>
            
            <button 
              @click="showCreateForm = !showCreateForm" 
              class="bg-purple-600 hover:bg-purple-700 text-white px-6 py-2 rounded-lg transition-colors duration-200 inline-flex items-center"
            >
              <i class="fas fa-plus mr-2"></i>
              Nuevo Usuario
            </button>
          </div>
        </div>
      </div>

      <!-- Formulario de creación -->
      <div v-if="showCreateForm" class="bg-white shadow-lg rounded-xl mb-8 p-6">
        <h3 class="text-xl font-bold text-gray-900 mb-4">Crear Nuevo Usuario</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nombre</label>
            <input 
              v-model="newUser.nombre"
              type="text" 
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
              placeholder="Nombre completo"
            >
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input 
              v-model="newUser.email"
              type="email" 
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
              placeholder="email@municipio.gob.mx"
            >
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Teléfono</label>
            <input 
              v-model="newUser.telefono"
              type="text" 
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
              placeholder="33-1234-5678"
            >
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Departamento</label>
            <select 
              v-model="newUser.departamento"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">Seleccionar...</option>
              <option value="Sistemas">Sistemas</option>
              <option value="Catastral">Catastral</option>
              <option value="Recaudación">Recaudación</option>
              <option value="Licencias">Licencias</option>
              <option value="Estacionamientos">Estacionamientos</option>
              <option value="Mercados">Mercados</option>
            </select>
          </div>
        </div>
        <div class="flex space-x-4 mt-6">
          <button 
            @click="createUser"
            :disabled="!canCreate || loading"
            class="bg-green-600 hover:bg-green-700 disabled:bg-gray-400 text-white px-6 py-2 rounded-lg transition-colors duration-200"
          >
            Crear Usuario
          </button>
          <button 
            @click="cancelCreate"
            class="bg-gray-600 hover:bg-gray-700 text-white px-6 py-2 rounded-lg transition-colors duration-200"
          >
            Cancelar
          </button>
        </div>
      </div>

      <!-- Alertas -->
      <div v-if="alert.show" class="mb-6 p-4 rounded-lg" :class="alert.type === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'">
        <div class="flex items-center">
          <i :class="alert.type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-triangle'" class="mr-2"></i>
          {{ alert.message }}
        </div>
      </div>

      <!-- Tabla de usuarios -->
      <div class="bg-white shadow-lg rounded-xl overflow-hidden">
        <div class="px-6 py-4 bg-gray-50 border-b">
          <h3 class="text-lg font-semibold text-gray-900">
            Lista de Usuarios ({{ users.length }} registros)
          </h3>
        </div>
        
        <div v-if="loading && users.length === 0" class="flex items-center justify-center py-12">
          <div class="text-center">
            <i class="fas fa-spinner fa-spin text-3xl text-blue-600 mb-4"></i>
            <p class="text-gray-600">Cargando usuarios...</p>
          </div>
        </div>
        
        <div v-else-if="users.length === 0" class="flex items-center justify-center py-12">
          <div class="text-center">
            <i class="fas fa-users text-3xl text-gray-400 mb-4"></i>
            <p class="text-gray-600">No hay usuarios registrados</p>
            <button 
              @click="loadUsers" 
              class="mt-4 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors duration-200"
            >
              Cargar Datos
            </button>
          </div>
        </div>
        
        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nombre</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Teléfono</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Departamento</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha Creación</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{{ user.id }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ user.nombre }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ user.email }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ user.telefono || '-' }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ user.departamento || '-' }}</td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span :class="user.activo ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'" 
                        class="px-2 py-1 text-xs font-semibold rounded-full">
                    {{ user.activo ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ formatDate(user.fecha_creacion) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Info técnica -->
      <div class="mt-8 bg-white shadow-lg rounded-xl p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Información Técnica</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div>
            <h4 class="text-sm font-medium text-gray-700 mb-2">Base de Datos</h4>
            <p class="text-sm text-gray-600">PostgreSQL</p>
            <p class="text-sm text-gray-600">DB: pavimentacion</p>
          </div>
          <div>
            <h4 class="text-sm font-medium text-gray-700 mb-2">Conexión</h4>
            <p class="text-sm text-gray-600">Host: localhost</p>
            <p class="text-sm text-gray-600">Puerto: 5432</p>
          </div>
          <div>
            <h4 class="text-sm font-medium text-gray-700 mb-2">Stored Procedure</h4>
            <p class="text-sm text-gray-600">sp_get_usuarios()</p>
            <p class="text-sm text-gray-600">Tabla: usuarios_test</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TestUsuarios',
  data() {
    return {
      users: [],
      loading: false,
      showCreateForm: false,
      connectionStatus: 'Sin probar',
      isConnected: false,
      alert: {
        show: false,
        type: 'success',
        message: ''
      },
      newUser: {
        nombre: '',
        email: '',
        telefono: '',
        departamento: ''
      }
    }
  },
  computed: {
    connectionStatusClass() {
      if (this.isConnected) {
        return 'bg-green-100 text-green-800'
      } else if (this.connectionStatus === 'Sin probar') {
        return 'bg-gray-100 text-gray-800'
      } else {
        return 'bg-red-100 text-red-800'
      }
    },
    connectionDotClass() {
      if (this.isConnected) {
        return 'bg-green-400'
      } else if (this.connectionStatus === 'Sin probar') {
        return 'bg-gray-400'
      } else {
        return 'bg-red-400'
      }
    },
    canCreate() {
      return this.newUser.nombre && this.newUser.email && this.newUser.departamento
    }
  },
  mounted() {
    this.testConnection()
  },
  methods: {
    async testConnection() {
      this.loading = true
      this.connectionStatus = 'Probando...'
      
      try {
        // Intentar conectar a PostgreSQL real primero
        const response = await fetch('http://localhost:8000/test-pgsql-native-real.php?action=test-connection')
        const data = await response.json()
        
        if (data.success) {
          this.isConnected = true
          this.connectionStatus = 'PostgreSQL Conectado'
          this.showAlert('success', 'Conexión exitosa a PostgreSQL: ' + data.message)
        } else {
          this.isConnected = false
          this.connectionStatus = 'Error PostgreSQL'
          this.showAlert('error', data.error || 'Error de conexión PostgreSQL')
        }
      } catch (error) {
        this.isConnected = false
        this.connectionStatus = 'Error'
        this.showAlert('error', 'Error de red: ' + error.message)
      } finally {
        this.loading = false
      }
    },
    
    async loadUsers() {
      this.loading = true
      
      try {
        // Intentar setup primero, luego listar
        const setupResponse = await fetch('http://localhost:8000/test-pgsql-native-real.php?action=setup')
        const setupData = await setupResponse.json()
        
        if (setupData.success) {
          // Ahora cargar usuarios
          const response = await fetch('http://localhost:8000/test-pgsql-native-real.php?action=list')
          const data = await response.json()
          
          if (data.success) {
            this.users = data.data
            this.showAlert('success', `${data.total} usuarios cargados desde PostgreSQL`)
          } else {
            this.showAlert('error', data.error || 'Error al cargar usuarios')
          }
        } else {
          this.showAlert('error', setupData.error || 'Error en setup inicial')
        }
      } catch (error) {
        this.showAlert('error', 'Error de red: ' + error.message)
      } finally {
        this.loading = false
      }
    },
    
    async createUser() {
      this.loading = true
      
      try {
        const response = await fetch('http://localhost:8000/test-pgsql-native-real.php?action=create', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(this.newUser)
        })
        
        const data = await response.json()
        
        if (data.success) {
          this.showAlert('success', 'Usuario creado correctamente en PostgreSQL')
          this.cancelCreate()
          await this.loadUsers() // Recargar la lista
        } else {
          this.showAlert('error', data.error || 'Error al crear usuario')
        }
      } catch (error) {
        this.showAlert('error', 'Error de red: ' + error.message)
      } finally {
        this.loading = false
      }
    },
    
    cancelCreate() {
      this.showCreateForm = false
      this.newUser = {
        nombre: '',
        email: '',
        telefono: '',
        departamento: ''
      }
    },
    
    showAlert(type, message) {
      this.alert = {
        show: true,
        type,
        message
      }
      
      setTimeout(() => {
        this.alert.show = false
      }, 5000)
    },
    
    formatDate(dateString) {
      if (!dateString) return '-'
      return new Date(dateString).toLocaleDateString('es-MX', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  }
}
</script>