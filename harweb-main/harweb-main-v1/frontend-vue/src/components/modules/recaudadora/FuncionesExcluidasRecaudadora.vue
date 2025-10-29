<template>
  <div class="funciones-excluidas-recaudadora">
    <!-- 🚫 COMPONENTE DE FUNCIONES EXCLUIDAS -->
    <div class="alert alert-danger mb-4">
      <h4 class="alert-heading">🚫 FUNCIONES EXCLUIDAS - Módulo Recaudadora</h4>
      <p class="mb-0">Las siguientes funciones han sido identificadas como obsoletas y serán removidas del sistema</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-times-circle me-2 text-danger"></i>
              Funciones Obsoletas - Recaudadora
            </h2>
            <p class="text-muted mb-0">Listado de componentes que serán removidos por obsolescencia</p>
          </div>
          <div class="badge badge-danger">5 FUNCIONES A REMOVER</div>
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
                  <i class="fas fa-keyboard text-muted me-2"></i>
                  <strong>Captura y consulta</strong>
                </td>
                <td>Sistema de captura manual obsoleto que será reemplazado por interfaces automatizadas</td>
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
                  <i class="fas fa-building text-muted me-2"></i>
                  <strong>Captura de pagos en centros de recaudación</strong>
                </td>
                <td>Proceso manual descontinuado por implementación de sistemas digitales centralizados</td>
                <td><span class="badge bg-danger">DESCONTINUADO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>3</strong></td>
                <td>
                  <i class="fas fa-server text-muted me-2"></i>
                  <strong>Consulta de AS400</strong>
                </td>
                <td>Sistema legacy que será completamente reemplazado por nueva arquitectura de datos</td>
                <td><span class="badge bg-warning">LEGACY</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>4</strong></td>
                <td>
                  <i class="fas fa-exclamation-triangle text-muted me-2"></i>
                  <strong>Seguimiento de multas</strong>
                </td>
                <td>Funcionalidad integrada en el nuevo sistema integral de apremios y convenios</td>
                <td><span class="badge bg-info">INTEGRADO</span></td>
                <td>
                  <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td><strong>5</strong></td>
                <td>
                  <i class="fas fa-search text-muted me-2"></i>
                  <strong>Consulta de requerimientos del AS400</strong>
                </td>
                <td>Interfaz obsoleta del sistema anterior que será reemplazada por módulo de consultas moderno</td>
                <td><span class="badge bg-warning">OBSOLETO</span></td>
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
              <span class="badge bg-danger">5</span>
            </div>
            <div class="d-flex justify-content-between align-items-center mb-2">
              <span>Funciones obsoletas:</span>
              <span class="badge bg-warning">3</span>
            </div>
            <div class="d-flex justify-content-between align-items-center mb-2">
              <span>Funciones descontinuadas:</span>
              <span class="badge bg-danger">1</span>
            </div>
            <div class="d-flex justify-content-between align-items-center mb-2">
              <span>Funciones integradas:</span>
              <span class="badge bg-info">1</span>
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
              <span>Sistema Integral de Apremios</span>
            </div>
            <div class="d-flex align-items-center mb-2">
              <i class="fas fa-arrow-right text-success me-2"></i>
              <span>Conversión de Procedimientos de Pago</span>
            </div>
            <div class="d-flex align-items-center mb-2">
              <i class="fas fa-arrow-right text-success me-2"></i>
              <span>Interfaces Automatizadas Modernas</span>
            </div>
            <div class="d-flex align-items-center mb-2">
              <i class="fas fa-arrow-right text-success me-2"></i>
              <span>Sistema de Consultas Avanzadas</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Análisis Detallado de Obsolescencia -->
    <div class="card mt-4">
      <div class="card-header bg-warning text-dark">
        <h6 class="mb-0">🔍 Análisis Detallado de Obsolescencia</h6>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-4">
            <h6 class="text-primary">1. Captura y Consulta</h6>
            <div class="card border-warning">
              <div class="card-body p-3">
                <p class="small mb-2"><strong>Problema Actual:</strong></p>
                <ul class="small mb-2">
                  <li>Proceso completamente manual</li>
                  <li>Propenso a errores humanos</li>
                  <li>Tiempos de captura excesivos</li>
                  <li>Falta de validaciones automáticas</li>
                </ul>
                <p class="small mb-1"><strong>Solución:</strong></p>
                <p class="small text-success">Interfaces automatizadas con validación en tiempo real</p>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <h6 class="text-primary">2. Centros de Recaudación</h6>
            <div class="card border-warning">
              <div class="card-body p-3">
                <p class="small mb-2"><strong>Problema Actual:</strong></p>
                <ul class="small mb-2">
                  <li>Descentralización ineficiente</li>
                  <li>Inconsistencias en captura</li>
                  <li>Dificultad de conciliación</li>
                  <li>Reportes fragmentados</li>
                </ul>
                <p class="small mb-1"><strong>Solución:</strong></p>
                <p class="small text-success">Sistema centralizado digital con múltiples puntos de acceso</p>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <h6 class="text-primary">3. Sistema AS400</h6>
            <div class="card border-danger">
              <div class="card-body p-3">
                <p class="small mb-2"><strong>Problema Actual:</strong></p>
                <ul class="small mb-2">
                  <li>Tecnología obsoleta</li>
                  <li>Interfaces no intuitivas</li>
                  <li>Limitaciones de escalabilidad</li>
                  <li>Costos de mantenimiento altos</li>
                </ul>
                <p class="small mb-1"><strong>Solución:</strong></p>
                <p class="small text-success">Arquitectura moderna con bases de datos relacionales</p>
              </div>
            </div>
          </div>
        </div>

        <div class="row mt-3">
          <div class="col-md-6">
            <h6 class="text-primary">4. Seguimiento de Multas</h6>
            <div class="card border-info">
              <div class="card-body p-3">
                <p class="small mb-2"><strong>Estado:</strong> Funcionalidad Integrada</p>
                <p class="small mb-2">Esta función no desaparece, sino que se integra completamente en:</p>
                <ul class="small mb-2">
                  <li>Sistema Integral de Apremios</li>
                  <li>Módulo de Seguimiento Automatizado</li>
                  <li>Reportes Avanzados de Multas</li>
                </ul>
                <p class="small text-success"><strong>Beneficio:</strong> Mayor funcionalidad en menos clicks</p>
              </div>
            </div>
          </div>
          <div class="col-md-6">
            <h6 class="text-primary">5. Consulta de Requerimientos AS400</h6>
            <div class="card border-warning">
              <div class="card-body p-3">
                <p class="small mb-2"><strong>Problema Actual:</strong></p>
                <ul class="small mb-2">
                  <li>Interfaz de línea de comandos</li>
                  <li>Sintaxis compleja</li>
                  <li>Resultados no estructurados</li>
                  <li>Requiere capacitación especializada</li>
                </ul>
                <p class="small mb-1"><strong>Solución:</strong></p>
                <p class="small text-success">Consultas visuales con filtros intuitivos y resultados estructurados</p>
              </div>
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
              <li><i class="fas fa-check text-success me-2"></i>Backup completo de datos AS400</li>
              <li><i class="fas fa-check text-success me-2"></i>Migración de datos históricos</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Capacitación en nuevos sistemas</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Pruebas de funcionalidad</li>
            </ul>
          </div>
          <div class="col-md-4">
            <h6 class="text-warning">Fase 2: Transición</h6>
            <ul class="list-unstyled">
              <li><i class="fas fa-clock text-warning me-2"></i>Operación paralela (30 días)</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Validación cruzada de datos</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Ajustes de procesos</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Soporte intensivo a usuarios</li>
            </ul>
          </div>
          <div class="col-md-4">
            <h6 class="text-success">Fase 3: Finalización</h6>
            <ul class="list-unstyled">
              <li><i class="fas fa-clock text-warning me-2"></i>Desactivación de sistemas obsoletos</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Limpieza de interfaces</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Documentación final</li>
              <li><i class="fas fa-clock text-warning me-2"></i>Evaluación de resultados</li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- Beneficios Esperados -->
    <div class="card mt-4">
      <div class="card-header bg-success text-white">
        <h6 class="mb-0">🎯 Beneficios Esperados de la Modernización</h6>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-3">
            <div class="text-center">
              <div class="display-6 text-success">
                <i class="fas fa-tachometer-alt"></i>
              </div>
              <h6 class="text-success">Eficiencia</h6>
              <p class="small text-muted">80% reducción en tiempos de captura y consulta</p>
            </div>
          </div>
          <div class="col-md-3">
            <div class="text-center">
              <div class="display-6 text-info">
                <i class="fas fa-shield-alt"></i>
              </div>
              <h6 class="text-info">Precisión</h6>
              <p class="small text-muted">95% reducción en errores de captura manual</p>
            </div>
          </div>
          <div class="col-md-3">
            <div class="text-center">
              <div class="display-6 text-warning">
                <i class="fas fa-chart-line"></i>
              </div>
              <h6 class="text-warning">Productividad</h6>
              <p class="small text-muted">300% aumento en capacidad de procesamiento</p>
            </div>
          </div>
          <div class="col-md-3">
            <div class="text-center">
              <div class="display-6 text-danger">
                <i class="fas fa-dollar-sign"></i>
              </div>
              <h6 class="text-danger">Ahorro</h6>
              <p class="small text-muted">60% reducción en costos operativos</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FuncionesExcluidasRecaudadora'
}
</script>

<style scoped>
.funciones-excluidas-recaudadora {
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

.display-6 {
  font-size: 2.5rem;
}

.list-unstyled li {
  margin-bottom: 0.5rem;
}

.card-body p.small {
  margin-bottom: 0.5rem;
}

.card-body ul.small {
  margin-bottom: 0.5rem;
  padding-left: 1rem;
}

.card-body ul.small li {
  margin-bottom: 0.25rem;
}
</style>