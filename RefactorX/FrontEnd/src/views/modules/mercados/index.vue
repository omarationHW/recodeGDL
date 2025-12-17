<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Módulo de Mercados</h1>
        <p class="module-description">
          Sistema de gestión integral para mercados municipales
        </p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="welcome-section">
        <h2>Bienvenido al Sistema de Mercados</h2>
        <p>Gestione de manera eficiente todos los aspectos relacionados con los mercados municipales.</p>
      </div>

      <div class="modules-grid">
        <div class="module-card">
          <div class="card-icon">
            <font-awesome-icon icon="building" />
          </div>
          <h3>Padrón de Locales</h3>
          <p>Gestión del registro y control de locales comerciales en los mercados.</p>
        </div>

        <div class="module-card">
          <div class="card-icon">
            <font-awesome-icon icon="tools" />
          </div>
          <h3>Mantenimiento</h3>
          <p>Control y seguimiento del mantenimiento de instalaciones y locales.</p>
        </div>

        <div class="module-card">
          <div class="card-icon">
            <font-awesome-icon icon="file-invoice-dollar" />
          </div>
          <h3>Adeudos</h3>
          <p>Administración de adeudos y cuentas pendientes de locatarios.</p>
        </div>

        <div class="module-card">
          <div class="card-icon">
            <font-awesome-icon icon="money-bill-wave" />
          </div>
          <h3>Recaudadoras</h3>
          <p>Gestión de recaudadoras y control de pagos de mercados.</p>
        </div>

        <div class="module-card">
          <div class="card-icon">
            <font-awesome-icon icon="cash-register" />
          </div>
          <h3>Alta de Pagos</h3>
          <p>Registro y control de pagos realizados por locatarios.</p>
        </div>

        <div class="module-card">
          <div class="card-icon">
            <font-awesome-icon icon="chart-line" />
          </div>
          <h3>Reportes</h3>
          <p>Consulta de reportes estadísticos y de operación.</p>
        </div>
      </div>

      <div class="info-section">
        <font-awesome-icon icon="info-circle" />
        <span>Utilice el menú lateral para acceder a las diferentes funcionalidades del sistema.</span>
      </div>
    </div>
  </div>
</template>

<script setup>
// No necesitamos importar componentes de layout ya que MainLayout los proporciona
</script>

<style scoped>
.module-view {
  padding: 2rem;
  min-height: calc(100vh - 120px);
  background: #f5f7fa;
}

.module-view-header {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 2px solid #e2e8f0;
}

.module-view-icon {
  width: 64px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #ea8215 0%, #c96d12 100%);
  border-radius: 12px;
  color: white;
  font-size: 2rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.module-view-info h1 {
  margin: 0;
  color: #1e293b;
  font-size: 2rem;
  font-weight: 700;
}

.module-description {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #64748b;
  font-size: 1.1rem;
  margin: 0.5rem 0 0 0;
}

.module-view-content {
  padding: 1rem 0;
}

.welcome-section {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: 2rem;
  margin-bottom: 2rem;
  text-align: center;
}

.welcome-section h2 {
  color: #1e293b;
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0 0 1rem 0;
}

.welcome-section p {
  color: #64748b;
  font-size: 1.1rem;
  margin: 0;
  line-height: 1.6;
}

.modules-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.module-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.module-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  border-color: #ea8215;
}

.card-icon {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #ea8215 0%, #c96d12 100%);
  border-radius: 8px;
  color: white;
  font-size: 1.5rem;
  margin-bottom: 1rem;
}

.module-card h3 {
  color: #1e293b;
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
}

.module-card p {
  color: #64748b;
  font-size: 0.95rem;
  line-height: 1.5;
  margin: 0;
}

.info-section {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  justify-content: center;
  padding: 1.25rem;
  background: rgba(234, 130, 21, 0.1);
  border-radius: 8px;
  color: #ea8215;
  font-weight: 500;
}
</style>
