<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="gavel" /></div>
      <div class="module-view-info">
        <h1>Multas y Reglamentos</h1>
        <p>Seleccione una operación del módulo</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Formularios del Módulo</h5>
          <div class="legend">
            <span class="badge badge-success"><font-awesome-icon icon="check-circle" /> Probado</span>
            <span class="badge badge-secondary"><font-awesome-icon icon="clock" /> Pendiente</span>
          </div>
        </div>
        <div class="municipal-card-body">
          <ul class="menu-list">
            <li>
              <router-link :to="{ name: 'multas-reglamentos-actualiza-fecha-empresas' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Actualiza Fecha Empresas
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-aplica-sdos-favor' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Aplica Saldos a Favor
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-autdescto' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Autorización de Descuento
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-bloqctasreqfrm' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Bloqueo de Cuentas
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-bloqueo-multa' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Bloqueo de Multa
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-catastro-dm' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Catastro DM
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-consreq400' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                ConsReq400
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-ligapago' }">
                <font-awesome-icon icon="check-circle" class="icon-tested" />
                Liga Pago
                <span class="badge badge-success">✓</span>
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-ligapagotra' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Liga Pago Tra
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-listareq' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Listado de Requerimientos
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-pagosmultfrm' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Pagos Multa FRM
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-req' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Requerimiento
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-reqfrm' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Requerimiento (Formulario)
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-reqtrans' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                ReqTrans
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-sdosfavor-ctrlexp' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Saldos a Favor - Control Expediente
              </router-link>
            </li>
            <li>
              <router-link :to="{ name: 'multas-reglamentos-sdosfavor-pagos' }">
                <font-awesome-icon icon="clock" class="icon-pending" />
                Saldos a Favor - Pagos
              </router-link>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// Vista de índice del módulo
</script>

<style scoped>
.menu-list {
  list-style: none;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 0.5rem;
}

.menu-list li {
  margin: 0;
}

.menu-list li a {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  border: 1px solid #dee2e6;
  border-radius: 0.375rem;
  text-decoration: none;
  color: #495057;
  transition: all 0.2s ease;
  background: white;
}

.menu-list li a:hover {
  background: #f8f9fa;
  border-color: #0d6efd;
  color: #0d6efd;
  transform: translateY(-2px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.icon-tested {
  color: #198754;
}

.icon-pending {
  color: #6c757d;
}

.badge {
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.75rem;
  font-weight: 600;
  margin-left: auto;
}

.badge-success {
  background-color: #198754;
  color: white;
}

.badge-secondary {
  background-color: #6c757d;
  color: white;
}

.legend {
  display: flex;
  gap: 1rem;
  font-size: 0.875rem;
}

.legend .badge {
  margin-left: 0;
}

.municipal-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid #dee2e6;
  background: #f8f9fa;
}

.municipal-card-header h5 {
  margin: 0;
  font-size: 1.125rem;
  font-weight: 600;
  color: #212529;
}
</style>
