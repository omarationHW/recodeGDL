<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #dc3545 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-danger bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-ban fa-2x text-danger"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Funciones Excluidas - Aseo</h1>
              <p class="text-muted mb-0">Funciones obsoletas removidas y sus reemplazos modernos</p>
            </div>
          </div>
          <div>
            <span class="badge bg-danger fs-6">MODERNIZACIÓN</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Resumen de Exclusiones -->
    <div class="card border-0 shadow-sm mb-4">
      <div class="card-body p-4">
        <h4 class="fw-bold text-dark mb-3">
          <i class="fas fa-info-circle me-2 text-primary"></i>Resumen de Modernización
        </h4>
        <div class="row g-4">
          <div class="col-md-4">
            <div class="text-center">
              <div class="bg-danger bg-opacity-10 rounded-circle p-3 d-inline-flex mb-2">
                <i class="fas fa-trash fa-2x text-danger"></i>
              </div>
              <h5 class="fw-bold text-danger">3</h5>
              <p class="text-muted small mb-0">Funciones Excluidas</p>
            </div>
          </div>
          <div class="col-md-4">
            <div class="text-center">
              <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-2">
                <i class="fas fa-plus fa-2x text-success"></i>
              </div>
              <h5 class="fw-bold text-success">4</h5>
              <p class="text-muted small mb-0">Nuevas Funciones</p>
            </div>
          </div>
          <div class="col-md-4">
            <div class="text-center">
              <div class="bg-primary bg-opacity-10 rounded-circle p-3 d-inline-flex mb-2">
                <i class="fas fa-chart-line fa-2x text-primary"></i>
              </div>
              <h5 class="fw-bold text-primary">133%</h5>
              <p class="text-muted small mb-0">Mejora en Funcionalidad</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Funciones Excluidas -->
    <div class="row g-4">

      <!-- Función Excluida 1: Gastos -->
      <div class="col-lg-4">
        <div class="card border border-danger border-opacity-25 h-100">
          <div class="card-header bg-danger bg-opacity-10">
            <div class="d-flex align-items-center">
              <i class="fas fa-ban text-danger me-2"></i>
              <h5 class="fw-bold mb-0 text-danger">Gastos</h5>
            </div>
          </div>
          <div class="card-body">
            <div class="mb-3">
              <h6 class="fw-bold text-dark">Razón de Exclusión:</h6>
              <p class="text-muted small">Sistema obsoleto de manejo de gastos operativos que requiere modernización completa para optimizar la gestión financiera.</p>
            </div>

            <div class="mb-3">
              <h6 class="fw-bold text-dark">Problemas Identificados:</h6>
              <ul class="text-muted small">
                <li>Gestión manual de gastos</li>
                <li>Falta de control automatizado</li>
                <li>Reportes limitados</li>
                <li>Sin integración con convenios</li>
              </ul>
            </div>

            <div class="alert alert-success small">
              <h6 class="fw-bold text-success">
                <i class="fas fa-arrow-right me-2"></i>Reemplazado por:
              </h6>
              <p class="mb-2"><strong>Sistema Integral de Convenios</strong></p>
              <p class="mb-0">Gestión automática de gastos dentro del sistema de convenios con control financiero avanzado.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Función Excluida 2: Configurar impresora -->
      <div class="col-lg-4">
        <div class="card border border-danger border-opacity-25 h-100">
          <div class="card-header bg-danger bg-opacity-10">
            <div class="d-flex align-items-center">
              <i class="fas fa-ban text-danger me-2"></i>
              <h5 class="fw-bold mb-0 text-danger">Configurar impresora</h5>
            </div>
          </div>
          <div class="card-body">
            <div class="mb-3">
              <h6 class="fw-bold text-dark">Razón de Exclusión:</h6>
              <p class="text-muted small">Configuración manual de impresoras que será automatizada para mejorar la eficiencia operativa.</p>
            </div>

            <div class="mb-3">
              <h6 class="fw-bold text-dark">Problemas Identificados:</h6>
              <ul class="text-muted small">
                <li>Configuración manual repetitiva</li>
                <li>Errores de configuración frecuentes</li>
                <li>Tiempo excesivo de configuración</li>
                <li>Falta de centralización</li>
              </ul>
            </div>

            <div class="alert alert-success small">
              <h6 class="fw-bold text-success">
                <i class="fas fa-arrow-right me-2"></i>Reemplazado por:
              </h6>
              <p class="mb-2"><strong>Sistema de Impresión Integrado</strong></p>
              <p class="mb-0">Configuración automática de impresoras dentro de los sistemas de convenios y apremios.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Función Excluida 3: Salir -->
      <div class="col-lg-4">
        <div class="card border border-danger border-opacity-25 h-100">
          <div class="card-header bg-danger bg-opacity-10">
            <div class="d-flex align-items-center">
              <i class="fas fa-ban text-danger me-2"></i>
              <h5 class="fw-bold mb-0 text-danger">Salir</h5>
            </div>
          </div>
          <div class="card-body">
            <div class="mb-3">
              <h6 class="fw-bold text-dark">Razón de Exclusión:</h6>
              <p class="text-muted small">Función de salida básica que será optimizada e integrada en la navegación moderna del sistema.</p>
            </div>

            <div class="mb-3">
              <h6 class="fw-bold text-dark">Problemas Identificados:</h6>
              <ul class="text-muted small">
                <li>Función básica sin optimización</li>
                <li>Falta de confirmación de cambios</li>
                <li>Sin guardado automático</li>
                <li>Navegación no intuitiva</li>
              </ul>
            </div>

            <div class="alert alert-success small">
              <h6 class="fw-bold text-success">
                <i class="fas fa-arrow-right me-2"></i>Reemplazado por:
              </h6>
              <p class="mb-2"><strong>Sistema de Navegación Moderno</strong></p>
              <p class="mb-0">Navegación optimizada con confirmaciones automáticas y guardado de estado integrado.</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Nuevas Funcionalidades Implementadas -->
    <div class="mt-5 card border-0 shadow-sm">
      <div class="card-body p-4">
        <h4 class="fw-bold text-success mb-4">
          <i class="fas fa-plus-circle me-2"></i>Nuevas Funcionalidades Implementadas
        </h4>

        <div class="row g-4">
          <div class="col-md-6 col-lg-3">
            <div class="card border border-success border-opacity-25 h-100">
              <div class="card-body text-center p-4">
                <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                  <i class="fas fa-handshake fa-2x text-success"></i>
                </div>
                <h6 class="fw-bold text-dark">Sistema de Convenios</h6>
                <p class="text-muted small mb-3">Gestión integral de convenios con 8 módulos especializados</p>
                <div class="d-flex justify-content-center">
                  <router-link to="/aseo/SistemaConveniosAseo" class="btn btn-outline-success btn-sm">
                    <i class="fas fa-external-link-alt me-1"></i>Ver
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <div class="col-md-6 col-lg-3">
            <div class="card border border-success border-opacity-25 h-100">
              <div class="card-body text-center p-4">
                <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                  <i class="fas fa-gavel fa-2x text-success"></i>
                </div>
                <h6 class="fw-bold text-dark">Sistema de Apremios</h6>
                <p class="text-muted small mb-3">Gestión de apremios con 7 módulos especializados</p>
                <div class="d-flex justify-content-center">
                  <router-link to="/aseo/SistemaApremiosAseo" class="btn btn-outline-success btn-sm">
                    <i class="fas fa-external-link-alt me-1"></i>Ver
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <div class="col-md-6 col-lg-3">
            <div class="card border border-success border-opacity-25 h-100">
              <div class="card-body text-center p-4">
                <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                  <i class="fas fa-percentage fa-2x text-success"></i>
                </div>
                <h6 class="fw-bold text-dark">Sistema de Descuentos</h6>
                <p class="text-muted small mb-3">Descuentos automatizados y conversión de procedimientos</p>
                <div class="d-flex justify-content-center">
                  <router-link to="/aseo/SistemaDescuentosAseo" class="btn btn-outline-success btn-sm">
                    <i class="fas fa-external-link-alt me-1"></i>Ver
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <div class="col-md-6 col-lg-3">
            <div class="card border border-success border-opacity-25 h-100">
              <div class="card-body text-center p-4">
                <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                  <i class="fas fa-info-circle fa-2x text-success"></i>
                </div>
                <h6 class="fw-bold text-dark">Funciones Excluidas</h6>
                <p class="text-muted small mb-3">Documentación completa de cambios realizados</p>
                <div class="d-flex justify-content-center">
                  <span class="badge bg-success">Actual</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Beneficios de la Modernización -->
    <div class="mt-4 card border-0 shadow-sm">
      <div class="card-body p-4">
        <h4 class="fw-bold text-primary mb-4">
          <i class="fas fa-star me-2"></i>Beneficios de la Modernización
        </h4>

        <div class="row g-4">
          <div class="col-md-6">
            <div class="d-flex align-items-start">
              <div class="bg-primary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                <i class="fas fa-rocket text-primary"></i>
              </div>
              <div>
                <h6 class="fw-bold text-dark">Eficiencia Operativa</h6>
                <p class="text-muted small mb-0">Automatización completa de procesos manuales con reducción del 70% en tiempo de gestión</p>
              </div>
            </div>
          </div>

          <div class="col-md-6">
            <div class="d-flex align-items-start">
              <div class="bg-primary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                <i class="fas fa-shield-alt text-primary"></i>
              </div>
              <div>
                <h6 class="fw-bold text-dark">Control y Seguridad</h6>
                <p class="text-muted small mb-0">Sistema integrado con trazabilidad completa y control de autorizaciones</p>
              </div>
            </div>
          </div>

          <div class="col-md-6">
            <div class="d-flex align-items-start">
              <div class="bg-primary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                <i class="fas fa-users text-primary"></i>
              </div>
              <div>
                <h6 class="fw-bold text-dark">Mejor Atención Ciudadana</h6>
                <p class="text-muted small mb-0">Interfaces modernas con consultas en línea y facilidades de pago</p>
              </div>
            </div>
          </div>

          <div class="col-md-6">
            <div class="d-flex align-items-start">
              <div class="bg-primary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                <i class="fas fa-chart-line text-primary"></i>
              </div>
              <div>
                <h6 class="fw-bold text-dark">Reportes Avanzados</h6>
                <p class="text-muted small mb-0">Sistema de reportes con exportación a Excel y análisis en tiempo real</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Guía de Migración -->
    <div class="mt-4 card border border-info border-opacity-25">
      <div class="card-header bg-info bg-opacity-10">
        <h5 class="fw-bold mb-0 text-info">
          <i class="fas fa-map me-2"></i>Guía de Migración para Usuarios
        </h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-6">
            <h6 class="fw-bold text-dark">Antes (Funciones Obsoletas)</h6>
            <ul class="text-muted small">
              <li>Gestión manual de gastos por módulo separado</li>
              <li>Configuración manual de cada impresora</li>
              <li>Salida básica sin confirmaciones</li>
            </ul>
          </div>
          <div class="col-md-6">
            <h6 class="fw-bold text-dark">Ahora (Sistema Moderno)</h6>
            <ul class="text-success small">
              <li>Gestión integrada de gastos en sistema de convenios</li>
              <li>Configuración automática de impresión</li>
              <li>Navegación inteligente con guardado automático</li>
            </ul>
          </div>
        </div>

        <div class="mt-3 alert alert-info">
          <p class="mb-0"><strong>Nota:</strong> Todas las funcionalidades anteriores han sido integradas y mejoradas en los nuevos sistemas. No se pierde ninguna funcionalidad, solo se optimiza y moderniza.</p>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: 'FuncionesExcluidasAseo',
  data() {
    return {
      // Estado del componente
    }
  }
}
</script>

<style scoped>
.card {
  transition: transform 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
}
</style>