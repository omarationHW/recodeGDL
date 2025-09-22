<template>
  <div class="funciones-excluidas-mercados">
    <!-- 🚫 COMPONENTE DE FUNCIONES EXCLUIDAS -->
    <div class="alert alert-danger mb-4">
      <h4 class="alert-heading">🚫 FUNCIONES EXCLUIDAS - Módulo Mercados</h4>
      <p class="mb-0">Las siguientes funciones han sido identificadas como obsoletas y serán removidas del sistema</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-times-circle me-2 text-danger"></i>
              Funciones Obsoletas - Mercados
            </h2>
            <p class="text-muted mb-0">Listado de componentes que serán removidos por obsolescencia</p>
          </div>
          <div class="badge badge-danger">10 FUNCIONES A REMOVER</div>
        </div>
      </div>
    </div>

    <!-- Lista de Funciones Excluidas -->
    <div class="card">
      <div class="card-header bg-danger text-white">
        <h5 class="mb-0">📋 Funciones a Excluir del Sistema</h5>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-striped">
            <thead class="table-danger">
              <tr>
                <th width="5%">#</th>
                <th width="30%">Función Obsoleta</th>
                <th width="35%">Motivo de Exclusión</th>
                <th width="20%">Estado Actual</th>
                <th width="10%">Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>1</strong></td>
                <td>
                  <i class="fas fa-key text-muted me-2"></i>
                  <strong>Claves de diferencias</strong>
                </td>
                <td>Sistema de diferenciación obsoleto que ya no se utiliza en procesos actuales</td>
                <td><span class="badge bg-warning">OBSOLETO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>2</strong></td>
                <td>
                  <i class="fas fa-calendar-check text-muted me-2"></i>
                  <strong>Autorizar fecha para carga de pagos</strong>
                </td>
                <td>Proceso manual innecesario, se automatizará en nuevo sistema</td>
                <td><span class="badge bg-warning">OBSOLETO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>3</strong></td>
                <td>
                  <i class="fas fa-music text-muted me-2"></i>
                  <strong>Tianguis cultural</strong>
                </td>
                <td>Funcionalidad descontinuada por el área usuaria</td>
                <td><span class="badge bg-danger">DESCONTINUADO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>4</strong></td>
                <td>
                  <i class="fas fa-upload text-muted me-2"></i>
                  <strong>Carga por mercado</strong>
                </td>
                <td>Método de carga obsoleto, será reemplazado por sistema integrado</td>
                <td><span class="badge bg-warning">OBSOLETO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>5</strong></td>
                <td>
                  <i class="fas fa-money-bill text-muted me-2"></i>
                  <strong>Carga pagos de diversos</strong>
                </td>
                <td>Sistema de pagos anticuado que no cumple estándares actuales</td>
                <td><span class="badge bg-warning">OBSOLETO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>6</strong></td>
                <td>
                  <i class="fas fa-user text-muted me-2"></i>
                  <strong>Carga individual</strong>
                </td>
                <td>Proceso individual ineficiente, será automatizado</td>
                <td><span class="badge bg-warning">OBSOLETO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>7</strong></td>
                <td>
                  <i class="fas fa-sign-out-alt text-muted me-2"></i>
                  <strong>Salir del módulo</strong>
                </td>
                <td>Función de navegación obsoleta en nueva arquitectura</td>
                <td><span class="badge bg-warning">OBSOLETO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>8</strong></td>
                <td>
                  <i class="fas fa-arrow-right text-muted me-2"></i>
                  <strong>Paso pagos de mercados</strong>
                </td>
                <td>Transferencia manual obsoleta, se integrará automáticamente</td>
                <td><span class="badge bg-warning">OBSOLETO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>9</strong></td>
                <td>
                  <i class="fas fa-bolt text-muted me-2"></i>
                  <strong>Paso pagos de energía</strong>
                </td>
                <td>Sistema de energía anticuado que será modernizado</td>
                <td><span class="badge bg-warning">OBSOLETO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>10</strong></td>
                <td>
                  <i class="fas fa-exclamation-triangle text-muted me-2"></i>
                  <strong>Paso adeudos</strong>
                </td>
                <td>Gestión de adeudos obsoleta, será reemplazada por sistema de convenios</td>
                <td><span class="badge bg-danger">CRÍTICO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Resumen y Reemplazo -->
    <div class="row mt-4">
      <div class="col-md-6">
        <div class="card border-danger">
          <div class="card-header bg-danger text-white">
            <h6 class="mb-0">📊 Resumen de Exclusiones</h6>
          </div>
          <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-2">
              <span>Total funciones a excluir:</span>
              <span class="badge bg-danger">10</span>
            </div>
            <div class="d-flex justify-content-between align-items-center mb-2">
              <span>Funciones obsoletas:</span>
              <span class="badge bg-warning">8</span>
            </div>
            <div class="d-flex justify-content-between align-items-center mb-2">
              <span>Funciones descontinuadas:</span>
              <span class="badge bg-danger">2</span>
            </div>
            <hr>
            <div class="d-flex justify-content-between align-items-center">
              <span><strong>Impacto en sistema:</strong></span>
              <span class="text-success"><strong>POSITIVO</strong></span>
            </div>
          </div>
        </div>
      </div>

      <div class="col-md-6">
        <div class="card border-success">
          <div class="card-header bg-success text-white">
            <h6 class="mb-0">🔄 Funciones de Reemplazo</h6>
          </div>
          <div class="card-body">
            <div class="d-flex align-items-center mb-2">
              <i class="fas fa-arrow-right text-success me-2"></i>
              <span>Sistema Integral de Convenios</span>
            </div>
            <div class="d-flex align-items-center mb-2">
              <i class="fas fa-arrow-right text-success me-2"></i>
              <span>ABC de Intereses Automatizado</span>
            </div>
            <div class="d-flex align-items-center mb-2">
              <i class="fas fa-arrow-right text-success me-2"></i>
              <span>Gestión de Parcialidades Inteligente</span>
            </div>
            <div class="d-flex align-items-center mb-2">
              <i class="fas fa-arrow-right text-success me-2"></i>
              <span>Sistema de Pagos Modernizado</span>
            </div>
            <div class="d-flex align-items-center mb-2">
              <i class="fas fa-arrow-right text-success me-2"></i>
              <span>Reportes Integrales Avanzados</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Plan de Migración -->
    <div class="card mt-4">
      <div class="card-header bg-info text-white">
        <h6 class="mb-0">📋 Plan de Migración y Remoción</h6>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-4">
            <h6 class="text-primary">Fase 1: Preparación</h6>
            <ul class="list-unstyled">
              <li><i class="fas fa-check text-success me-2"></i>Backup de datos existentes</li>
              <li><i class="fas fa-check text-success me-2"></i>Análisis de dependencias</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Notificación a usuarios</li>
            </ul>
          </div>
          <div class="col-md-4">
            <h6 class="text-warning">Fase 2: Desactivación</h6>
            <ul class="list-unstyled">
              <li><i class="fas fa-clock text-warning me-2"></i>Desactivación gradual</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Monitoreo de impacto</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Soporte a usuarios</li>
            </ul>
          </div>
          <div class="col-md-4">
            <h6 class="text-success">Fase 3: Implementación</h6>
            <ul class="list-unstyled">
              <li><i class="fas fa-clock text-warning me-2"></i>Nuevas funcionalidades</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Migración de datos</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Capacitación usuarios</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FuncionesExcluidasMercados'
}
</script>

<style scoped>
.funciones-excluidas-mercados {
  padding: 1rem;
}

.alert-danger {
  border-left: 4px solid #dc3545;
}

.table tbody tr:hover {
  background-color: #fff3cd;
}

.badge {
  font-size: 0.75rem;
}
</style>