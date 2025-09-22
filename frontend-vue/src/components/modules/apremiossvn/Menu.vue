<template>
  <div class="apremios-menu">
    <div class="menu-header">
      <h1>Módulo de Apremios</h1>
      <p>Sistema de Cobranza Coactiva</p>
    </div>

    <div class="menu-grid">
      <!-- Sección de Consultas -->
      <div class="menu-section">
        <h2>Consultas</h2>
        <div class="menu-items">
          <router-link to="/apremios/individual-folio" class="menu-item">
            <i class="fas fa-search"></i>
            <span>Consulta Individual por Folio</span>
          </router-link>
          
          <router-link to="/apremios/listados-ade" class="menu-item">
            <i class="fas fa-list"></i>
            <span>Listados de Adeudos</span>
          </router-link>
          
          <router-link to="/apremios/list-reg" class="menu-item">
            <i class="fas fa-clipboard-list"></i>
            <span>Listado por Registro</span>
          </router-link>
        </div>
      </div>

      <!-- Sección de Gestión -->
      <div class="menu-section">
        <h2>Gestión</h2>
        <div class="menu-items">
          <router-link to="/apremios/list-eje" class="menu-item">
            <i class="fas fa-users"></i>
            <span>Lista de Ejecutores</span>
          </router-link>
          
          <router-link to="/apremios/modificar-bien" class="menu-item">
            <i class="fas fa-edit"></i>
            <span>Modificar Bien</span>
          </router-link>
          
          <router-link to="/apremios/notificaciones" class="menu-item">
            <i class="fas fa-bell"></i>
            <span>Notificaciones</span>
          </router-link>
        </div>
      </div>

      <!-- Sección de Reportes -->
      <div class="menu-section">
        <h2>Reportes</h2>
        <div class="menu-items">
          <router-link to="/apremios/rprt-catal-eje" class="menu-item">
            <i class="fas fa-chart-bar"></i>
            <span>Catálogo de Ejecutores</span>
          </router-link>
          
          <router-link to="/apremios/carta-invitacion" class="menu-item">
            <i class="fas fa-envelope"></i>
            <span>Carta de Invitación</span>
          </router-link>
          
          <router-link to="/apremios/recuperacion" class="menu-item">
            <i class="fas fa-recycle"></i>
            <span>Recuperación</span>
          </router-link>
        </div>
      </div>

      <!-- Sección de Configuración -->
      <div class="menu-section">
        <h2>Configuración</h2>
        <div class="menu-items">
          <router-link to="/apremios/acceso" class="menu-item">
            <i class="fas fa-key"></i>
            <span>Control de Acceso</span>
          </router-link>
          
          <router-link to="/apremios/exportar-excel" class="menu-item">
            <i class="fas fa-file-excel"></i>
            <span>Exportar a Excel</span>
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ApremiosMenu',
  data() {
    return {
      currentDate: new Date().toLocaleDateString('es-MX')
    }
  },
  methods: {
    goToModule(route) {
      this.$router.push(route);
    }
  }
}
</script>

<style scoped>
.apremios-menu {
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

.menu-header {
  text-align: center;
  color: white;
  margin-bottom: 40px;
}

.menu-header h1 {
  font-size: 3rem;
  margin-bottom: 10px;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
}

.menu-header p {
  font-size: 1.2rem;
  opacity: 0.9;
}

.menu-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 30px;
  max-width: 1200px;
  margin: 0 auto;
}

.menu-section {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
  transition: transform 0.3s ease;
}

.menu-section:hover {
  transform: translateY(-5px);
}

.menu-section h2 {
  color: #667eea;
  font-size: 1.5rem;
  margin-bottom: 20px;
  border-bottom: 3px solid #667eea;
  padding-bottom: 10px;
}

.menu-items {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 15px 20px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 10px;
  text-decoration: none;
  color: #495057;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.menu-item:hover {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  text-decoration: none;
  border-color: #ffffff30;
  transform: translateX(5px);
}

.menu-item i {
  font-size: 1.2rem;
  margin-right: 15px;
  width: 20px;
  text-align: center;
}

.menu-item span {
  font-weight: 500;
  font-size: 1rem;
}

@media (max-width: 768px) {
  .menu-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .menu-header h1 {
    font-size: 2rem;
  }
  
  .menu-section {
    padding: 20px;
  }
  
  .menu-item {
    padding: 12px 15px;
  }
}
</style>